#!/bin/bash
set -e

# Check if cloudflared is enabled
if [ "${ENABLE_CLOUDFLARE}" != "true" ]; then
    echo "Cloudflare tunnel is disabled. Exiting."
    exit 0
fi

# Check for credentials
if [ -z "${CLOUDFLARE_TUNNEL_TOKEN}" ] && [ -z "${CLOUDFLARE_TUNNEL_ID}" ]; then
    echo "Warning: Cloudflare tunnel is enabled but neither CLOUDFLARE_TUNNEL_TOKEN nor CLOUDFLARE_TUNNEL_ID is set"
    echo "Please set either CLOUDFLARE_TUNNEL_TOKEN or CLOUDFLARE_TUNNEL_ID in your .env file"
    exit 1
fi

# Start tunnel based on provided credentials
if [ -n "${CLOUDFLARE_TUNNEL_TOKEN}" ]; then
    echo "Starting Cloudflare tunnel with token..."
    exec cloudflared tunnel --no-autoupdate run --token "${CLOUDFLARE_TUNNEL_TOKEN}"
elif [ -n "${CLOUDFLARE_TUNNEL_ID}" ]; then
    echo "Starting Cloudflare tunnel with ID..."
    exec cloudflared tunnel --no-autoupdate run "${CLOUDFLARE_TUNNEL_ID}"
fi