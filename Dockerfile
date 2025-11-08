# Stage 1: Build stage
FROM ubuntu:latest AS builder

# Install dependencies for downloading and setting up WARP
RUN apt-get update && \
    apt-get install -y \
    curl \
    gpg \
    lsb-release \
    apt-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up Cloudflare WARP repository and download package
RUN curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/cloudflare-client.list && \
    apt-get update && \
    apt-get download cloudflare-warp && \
    mkdir -p /warp-package && \
    mv cloudflare-warp*.deb /warp-package/

# Stage 2: Final image
FROM ubuntu:latest

# Copy WARP package from builder stage
COPY --from=builder /warp-package/cloudflare-warp*.deb /tmp/

# Install minimal dependencies and WARP
RUN apt-get update && \
    apt-get install -y \
    dbus \
    dbus-x11 \
    procps \
    sudo && \
    dpkg -i /tmp/cloudflare-warp*.deb || apt-get -f install -y && \
    rm /tmp/cloudflare-warp*.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory for ToS acceptance files
RUN mkdir -p /root/.local/share/warp/ && \
    echo "yes" > /root/.local/share/warp/accepted-tos.txt && \
    echo "yes" > /root/.local/share/warp/accepted-teams-tos.txt && \
    chmod 644 /root/.local/share/warp/accepted-tos.txt /root/.local/share/warp/accepted-teams-tos.txt

# Create TUN device directory
RUN mkdir -p /dev/net

# Copy startup script
COPY warp-startup.sh /warp-startup.sh
RUN chmod +x /warp-startup.sh 

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/warp-startup.sh"]