# Dockerfile
FROM hhftechnology/alpine:3.21
# Build arguments
ARG CLOUDFLARED_VERSION=2025.2.1
ARG TAILSCALE_VERSION=1.80.3
ARG NEWT_VERSION=1.1.0
ARG TARGETARCH

# Install base packages
RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    iptables \
    iproute2 \
    supervisor \
    linux-headers \
    build-base \
    kmod

# Install Tailscale
RUN curl -sL "https://pkgs.tailscale.com/stable/tailscale_${TAILSCALE_VERSION}_${TARGETARCH}.tgz" \
    | tar -zxf - -C /usr/local/bin --strip=1 \
    tailscale_${TAILSCALE_VERSION}_${TARGETARCH}/tailscaled \
    tailscale_${TAILSCALE_VERSION}_${TARGETARCH}/tailscale

# Install Cloudflared
RUN curl -sL "https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-${TARGETARCH}" \
    -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Install Newt
# Install Newt
RUN ARCH=$([ "${TARGETARCH}" = "amd64" ] && echo "amd64" || echo "arm64") && \
    curl -sL "https://github.com/fosrl/newt/releases/download/${NEWT_VERSION}/newt_linux_${ARCH}" \
    -o /usr/local/bin/newt && \
    chmod +x /usr/local/bin/newt


# Create necessary directories
RUN mkdir -p \
    /var/run/tailscale \
    /var/lib/tailscale \
    /var/log/supervisor \
    /etc/cloudflared

# Copy configuration and scripts
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/tailscale-up.sh /usr/local/bin/tailscale-up.sh
COPY scripts/cloudflared-up.sh /usr/local/bin/cloudflared-up.sh
COPY scripts/newt-up.sh /usr/local/bin/newt-up.sh

# Set execute permissions for scripts
RUN chmod +x \
    /entrypoint.sh \
    /usr/local/bin/tailscale-up.sh \
    /usr/local/bin/newt-up.sh \
    /usr/local/bin/cloudflared-up.sh

# Set environment variables
ENV TUNNEL_ORIGIN_CERT=/etc/cloudflared/cert.pem \
    NO_AUTOUPDATE=true

ENTRYPOINT ["/entrypoint.sh"]