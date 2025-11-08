# Cloudflare WARP Docker Container

This repository contains a Docker container for running Cloudflare WARP client in a containerized environment. It allows you to connect to Cloudflare's WARP network and access resources through Cloudflare Zero Trust.

## Overview

Cloudflare WARP is a free app that makes your Internet more secure by encrypting more of the traffic leaving your device. When paired with Cloudflare Zero Trust, it enables secure access to internal applications without a traditional VPN.

This container:
- Installs the Cloudflare WARP client in a minimal Ubuntu environment
- Provides automatic connection management
- Supports VNET selection through environment variables
- Includes health checks and automatic reconnection

## Requirements

- Docker installed on your host system
- A Cloudflare Zero Trust account with a WARP connector token

## Usage

### Basic Usage

```bash
docker run -d --name warp \
  --device=/dev/net/tun \
  --cap-add=NET_ADMIN \
  -e WARP_TOKEN=your-connector-token \
  ghcr.io/yourusername/cf-warp:latest
```

### Environment Variables

- `WARP_TOKEN` (required): Your Cloudflare WARP connector token
- `VNET` (optional): The name of the VNET to connect to (if not specified, the default VNET will be used)

### Checking Status

To check the status of the WARP connection:

```bash
docker logs warp
```

## Building the Image

To build the Docker image locally:

```bash
docker build -t cf-warp .
```

## How It Works

The container uses a multi-stage build to:

1. Download and prepare the Cloudflare WARP package
2. Install it in a minimal Ubuntu environment
3. Run a startup script that:
   - Creates necessary TUN device
   - Starts D-Bus daemon
   - Registers with Cloudflare using your token
   - Connects to WARP
   - Monitors connection status and reconnects if needed
   - Selects the appropriate VNET based on configuration

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This project is not affiliated with or endorsed by Cloudflare. Cloudflare WARP is a trademark of Cloudflare, Inc.