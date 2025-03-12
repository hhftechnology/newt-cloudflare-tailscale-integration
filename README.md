# Secure Access Gateway with Pangolin, Newt, Cloudflare and Tailscale

This Docker image provides a secure access gateway that integrates Pangolin's Newt client, Cloudflare Tunnels, and Tailscale for flexible and secure access to your services. You can use any combination of these technologies simultaneously to create a secure, zero-trust access layer for your applications.

## Features

- Pangolin Newt integration for secure tunneled access without port forwarding
- Cloudflare Tunnel integration for secure public access
- Tailscale VPN integration for private network access
- Support for multiple port forwarding
- Docker-compose ready
- Easy configuration through environment variables
- Automatic service discovery and configuration

## Prerequisites

Before using this image, you'll need:

1. A Pangolin deployment on a VPS (if using Newt)
2. A Cloudflare account (if using Cloudflare Tunnels)
3. A Tailscale account (if using Tailscale)
4. Docker and Docker Compose installed on your host
5. Basic understanding of networking and Docker concepts

## Environment Variables

### Core Configuration

```env
# Feature Flags
ENABLE_NEWT=true|false
ENABLE_CLOUDFLARE=true|false
ENABLE_TAILSCALE=true|false

# Newt Configuration (required if ENABLE_NEWT=true)
NEWT_ID=your-newt-id
NEWT_SECRET=your-newt-secret
PANGOLIN_ENDPOINT=https://example.com

# Cloudflare Configuration (required if ENABLE_CLOUDFLARE=true)
CLOUDFLARE_TUNNEL_TOKEN=your-tunnel-token
# OR
CLOUDFLARE_TUNNEL_ID=your-tunnel-id

# Tailscale Configuration (required if ENABLE_TAILSCALE=true)
TAILSCALE_AUTH_KEY=tskey-auth-xxxxx-xxxxxxxxxxxxx
TAILSCALE_HOSTNAME=your-preferred-hostname
TARGET_PORTS=3000,8080,9000  # Ports to forward via Tailscale
```

### Optional Tailscale Settings
```env
TAILSCALE_ACCEPT_DNS=true|false
TAILSCALE_ACCEPT_ROUTES=true|false
TAILSCALE_ADVERTISE_EXIT_NODE=true|false
TAILSCALE_ADVERTISE_ROUTES=
TAILSCALE_SSH=true|false
```

## Usage Examples

### Example 1: Using Newt with Pangolin

This example shows how to connect to a Pangolin server using Newt to securely expose services.

```yaml
services:
  secure-proxy:
    image: hhftechnology/newt-cloudflare-tailscale-integration:latest
    environment:
      - ENABLE_NEWT=true
      - ENABLE_CLOUDFLARE=false
      - ENABLE_TAILSCALE=false
      - NEWT_ID=your-newt-id
      - NEWT_SECRET=your-newt-secret
      - PANGOLIN_ENDPOINT=https://your-pangolin-server.com
    restart: unless-stopped

  webapp:
    image: nginx:alpine
    expose:
      - "80"
```

### Example 2: Combining Newt and Cloudflare

This example demonstrates using both Newt and Cloudflare Tunnel for redundant access methods.

```yaml
services:
  secure-proxy:
    image: hhftechnology/newt-cloudflare-tailscale-integration:latest
    environment:
      - ENABLE_NEWT=true
      - ENABLE_CLOUDFLARE=true
      - ENABLE_TAILSCALE=false
      - NEWT_ID=your-newt-id
      - NEWT_SECRET=your-newt-secret
      - PANGOLIN_ENDPOINT=https://your-pangolin-server.com
      - CLOUDFLARE_TUNNEL_TOKEN=your-tunnel-token
    volumes:
      - ./cloudflared:/etc/cloudflared
    restart: unless-stopped

  webapp:
    image: nginx:alpine
    expose:
      - "80"
```

### Example 3: Basic Web Application with Cloudflare Only

This example shows how to expose a simple web application through Cloudflare Tunnel.

```yaml
services:
  secure-proxy:
    image: hhftechnology/newt-cloudflare-tailscale-integration:latest
    environment:
      - ENABLE_NEWT=false
      - ENABLE_CLOUDFLARE=true
      - ENABLE_TAILSCALE=false
      - CLOUDFLARE_TUNNEL_TOKEN=your-tunnel-token
    volumes:
      - ./cloudflared:/etc/cloudflared
    restart: unless-stopped

  webapp:
    image: nginx:alpine
    expose:
      - "80"
```

### Example 4: Internal Service with Tailscale Only

This example demonstrates using Tailscale for private access to an internal dashboard.

```yaml
version: '3'
services:
  secure-proxy:
    image: hhftechnology/newt-cloudflare-tailscale-integration:latest
    cap_add:
      - NET_ADMIN
    environment:
      - ENABLE_NEWT=false
      - ENABLE_CLOUDFLARE=false
      - ENABLE_TAILSCALE=true
      - TAILSCALE_AUTH_KEY=tskey-auth-xxxxx-xxxxxxxxxxxxx
      - TAILSCALE_HOSTNAME=internal-dashboard
      - TARGET_PORTS=3000
    volumes:
      - ./data/tailscale:/var/lib/tailscale
    devices:
      - /dev/net/tun:/dev/net/tun

  dashboard:
    image: grafana/grafana
    expose:
      - "3000"
```

### Example 5: Complete Solution - Newt, Cloudflare, and Tailscale

This example shows how to use all three technologies together for comprehensive access options.

```yaml
services:
  secure-proxy:
    image: hhftechnology/newt-cloudflare-tailscale-integration:latest
    cap_add:
      - NET_ADMIN
    environment:
      - ENABLE_NEWT=true
      - ENABLE_CLOUDFLARE=true
      - ENABLE_TAILSCALE=true
      - NEWT_ID=your-newt-id
      - NEWT_SECRET=your-newt-secret
      - PANGOLIN_ENDPOINT=https://your-pangolin-server.com
      - CLOUDFLARE_TUNNEL_TOKEN=your-tunnel-token
      - TAILSCALE_AUTH_KEY=tskey-auth-xxxxx-xxxxxxxxxxxxx
      - TAILSCALE_HOSTNAME=hybrid-app
      - TARGET_PORTS=9000,5432
    volumes:
      - ./data/tailscale:/var/lib/tailscale
      - ./data/cloudflared:/etc/cloudflared
    devices:
      - /dev/net/tun:/dev/net/tun

  api:
    image: node:alpine
    expose:
      - "80"  # Public API via Cloudflare and Pangolin

  management:
    image: portainer/portainer-ce
    expose:
      - "9000"  # Access via Tailscale and Pangolin

  database:
    image: postgres:alpine
    expose:
      - "5432"  # Private database access via Tailscale and Pangolin
```

### Example 6: Microservices with Mixed Access

This example shows a microservices architecture with different access patterns for different services.

```yaml
services:
  secure-proxy:
    image: hhftechnology/newt-cloudflare-tailscale-integration:latest
    cap_add:
      - NET_ADMIN
    environment:
      - ENABLE_NEWT=true
      - ENABLE_CLOUDFLARE=true
      - ENABLE_TAILSCALE=true
      - NEWT_ID=your-newt-id
      - NEWT_SECRET=your-newt-secret
      - PANGOLIN_ENDPOINT=https://your-pangolin-server.com
      - CLOUDFLARE_TUNNEL_TOKEN=your-tunnel-token
      - TAILSCALE_AUTH_KEY=tskey-auth-xxxxx-xxxxxxxxxxxxx
      - TAILSCALE_HOSTNAME=microservices
      - TARGET_PORTS=8080,9090,3000,5432
    volumes:
      - ./data/tailscale:/var/lib/tailscale
      - ./data/cloudflared:/etc/cloudflared
    devices:
      - /dev/net/tun:/dev/net/tun

  gateway:
    image: nginx:alpine
    expose:
      - "80"  # Public API Gateway via all methods

  auth-service:
    image: node:alpine
    expose:
      - "8080"  # Private auth service via Tailscale and Newt

  metrics:
    image: prom/prometheus
    expose:
      - "9090"  # Private metrics via Tailscale and Newt

  admin-dashboard:
    image: grafana/grafana
    expose:
      - "3000"  # Private dashboard via Tailscale and Newt

  database:
    image: postgres:alpine
    expose:
      - "5432"  # Private database via Tailscale and Newt
```

## Network Architecture

When using multiple technologies together, the secure-proxy container acts as a gateway:

1. Newt provides a secure tunnel to your Pangolin server without needing to open ports on your network
2. Cloudflare Tunnel provides secure public access to services marked for public exposure
3. Tailscale provides private, encrypted access to services marked for internal use
4. The proxy automatically handles routing and network isolation

## How Technologies Compare

| Technology | Open Ports Required | Public Access | Private Access | Auth Method |
|------------|---------------------|---------------|----------------|-------------|
| Newt (Pangolin) | No | Yes (via Pangolin) | Yes | Pangolin Auth |
| Cloudflare Tunnel | No | Yes | Limited | Cloudflare Zero Trust |
| Tailscale | No | No | Yes | Tailscale Auth |

## Security Considerations

1. Always use strong authentication keys and tokens
2. Regularly rotate your credentials for all services
3. Monitor access logs and usage patterns
4. Keep the Docker image and all services updated
5. Follow the principle of least privilege when exposing services

## Troubleshooting

### Common Issues

1. Connection Issues:
```bash
# Check Newt status
docker exec secure-proxy newt status

# Check Tailscale status
docker exec secure-proxy tailscale status

# Check Cloudflare tunnel status
docker exec secure-proxy cloudflared tunnel info

# View logs
docker logs secure-proxy
```

2. Port Forwarding Issues:
```bash
# Check iptables rules
docker exec secure-proxy iptables -t nat -L PREROUTING

# Verify network interfaces
docker exec secure-proxy ip addr show
```

## Support

For issues, feature requests, or contributions, please visit our GitHub repository:
[https://github.com/hhftechnology/newt-cloudflare-tailscale-integration](https://github.com/hhftechnology/newt-cloudflare-tailscale-integration)

## License

MIT License - See LICENSE file for details