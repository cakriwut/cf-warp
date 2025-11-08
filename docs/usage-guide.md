# Cloudflare WARP Docker Container Usage Guide

This guide provides detailed instructions on how to use the Cloudflare WARP Docker container.

## Getting Started

### Prerequisites

- Docker installed on your host system
- A Cloudflare Zero Trust account
- A WARP connector token from your Cloudflare Zero Trust dashboard

### Obtaining a WARP Connector Token

1. Log in to your [Cloudflare Zero Trust dashboard](https://dash.teams.cloudflare.com/)
2. Navigate to Settings > WARP Client
3. Scroll down to "Device enrollment permissions"
4. Click "Generate a new token"
5. Copy the generated token

## Running the Container

### Basic Usage

```bash
docker run -d --name warp \
  --device=/dev/net/tun \
  --cap-add=NET_ADMIN \
  -e WARP_TOKEN=your-connector-token \
  yourusername/cf-warp:latest
```

### With VNET Selection

```bash
docker run -d --name warp \
  --device=/dev/net/tun \
  --cap-add=NET_ADMIN \
  -e WARP_TOKEN=your-connector-token \
  -e VNET=your-vnet-name \
  yourusername/cf-warp:latest
```

### Running in Host Network Mode

```bash
docker run -d --name warp \
  --network host \
  --device=/dev/net/tun \
  --cap-add=NET_ADMIN \
  -e WARP_TOKEN=your-connector-token \
  yourusername/cf-warp:latest
```

## Container Management

### Checking Connection Status

```bash
docker logs warp
```

### Stopping the Container

```bash
docker stop warp
```

### Removing the Container

```bash
docker rm warp
```

## Troubleshooting

### Connection Issues

If the container cannot connect to WARP:

1. Check that your connector token is valid
2. Ensure the container has internet access
3. Verify that the TUN device is properly created
4. Check the logs for specific error messages:
   ```bash
   docker logs warp
   ```

### VNET Selection Issues

If the container cannot select the specified VNET:

1. Verify that the VNET name is correct
2. Check that your Cloudflare Zero Trust account has access to the VNET
3. Look for specific error messages in the logs

## Advanced Configuration

### Persistent Storage

To persist WARP registration between container restarts:

```bash
docker run -d --name warp \
  --device=/dev/net/tun \
  --cap-add=NET_ADMIN \
  -e WARP_TOKEN=your-connector-token \
  -v warp-data:/var/lib/cloudflare-warp \
  yourusername/cf-warp:latest
```

### Custom DNS Settings

The container uses Cloudflare's DNS by default. To use custom DNS settings, you'll need to configure this through your Cloudflare Zero Trust dashboard.

## Using with Other Containers

To allow other containers to use the WARP connection, you can use Docker's network features:

1. Create a custom network:
   ```bash
   docker network create warp-net
   ```

2. Run the WARP container with this network:
   ```bash
   docker run -d --name warp \
     --network warp-net \
     --device=/dev/net/tun \
     --cap-add=NET_ADMIN \
     -e WARP_TOKEN=your-connector-token \
     yourusername/cf-warp:latest
   ```

3. Run other containers with the same network:
   ```bash
   docker run -d --name app \
     --network warp-net \
     your-app-image