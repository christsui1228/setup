#!/usr/bin/env bash

# ==============================================================================
# Docker Network Configuration Script for Mainland China
#
# This script configures the Docker daemon with:
# 1. Domestic registry mirrors for speed.
# 2. An HTTP/HTTPS proxy for fetching images not available on mirrors.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# Define some colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Main Function ---
main() {
    check_root
    configure_mirrors
    configure_proxy
    apply_changes
    verify_configuration
    print_success
}

# --- Helper Functions ---

# Function to check if the script is run as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${YELLOW}This script must be run as root. Please use 'sudo ./setup_docker_net.sh'${NC}"
        exit 1
    fi
}

# Function to configure registry mirrors
configure_mirrors() {
    echo -e "\n${GREEN}Step 1: Configuring Docker registry mirrors...${NC}"
    
    # Create docker directory if it doesn't exist
    mkdir -p /etc/docker

    # Write the daemon.json configuration using a here document
    tee /etc/docker/daemon.json <<EOF > /dev/null
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com",
    "https://dockerproxy.com",
    "https://ccr.ccs.tencentyun.com"
  ]
}
EOF
    echo "Wrote mirror configuration to /etc/docker/daemon.json"
}

# Function to configure the proxy for the Docker daemon
configure_proxy() {
    echo -e "\n${GREEN}Step 2: Configuring proxy for the Docker daemon...${NC}"
    
    local default_proxy="http://127.0.0.1:7890"
    local user_proxy
    
    # Prompt the user for their proxy address, with a default value
    read -p "Please enter your proxy address (e.g., http://127.0.0.1:7890) [default: ${default_proxy}]: " user_proxy
    
    # Use the default value if the user input is empty
    local proxy_url="${user_proxy:-$default_proxy}"
    
    echo "Using proxy: ${proxy_url}"
    
    # Create the systemd drop-in directory
    mkdir -p /etc/systemd/system/docker.service.d
    
    # Write the http-proxy.conf configuration
    tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF > /dev/null
[Service]
Environment="HTTP_PROXY=${proxy_url}"
Environment="HTTPS_PROXY=${proxy_url}"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF
    echo "Wrote proxy configuration to /etc/systemd/system/docker.service.d/http-proxy.conf"
}

# Function to apply changes and restart Docker
apply_changes() {
    echo -e "\n${GREEN}Step 3: Applying new configuration and restarting Docker...${NC}"
    echo "Running 'systemctl daemon-reload'..."
    systemctl daemon-reload
    
    echo "Running 'systemctl restart docker'..."
    systemctl restart docker
    
    # Give the daemon a moment to start up
    sleep 3
}

# Function to verify the final configuration
verify_configuration() {
    echo -e "\n${GREEN}Step 4: Verifying the configuration...${NC}"
    echo "Checking 'docker info' for mirrors and proxy settings:"
    
    # Use a variable to store docker info to avoid running it twice
    local docker_info_output
    if ! docker_info_output=$(docker info); then
        echo -e "${YELLOW}Could not run 'docker info'. The Docker daemon might have failed to start. Please check its status with 'systemctl status docker'.${NC}"
        exit 1
    fi

    # Check for mirrors and proxy
    if ! echo "$docker_info_output" | grep -q "Registry Mirrors"; then
        echo -e "${YELLOW}Warning: Registry Mirrors not found in configuration.${NC}"
    fi
    if ! echo "$docker_info_output" | grep -q "HTTP Proxy"; then
        echo -e "${YELLOW}Warning: HTTP Proxy not found in configuration.${NC}"
    fi

    # Print the relevant lines for the user to see
    echo "$docker_info_output" | grep -E "Registry Mirrors|HTTP Proxy|HTTPS Proxy|No Proxy" --color=never
}

print_success() {
    echo -e "\n${GREEN}=====================================================${NC}"
    echo -e "${GREEN}Docker network setup complete!${NC}"
    echo "Your Docker is now configured with domestic mirrors and a proxy fallback."
    echo "You can now try pulling an image, e.g., 'docker pull postgres:18.0'"
    echo -e "${GREEN}=====================================================${NC}"
}

# --- Script Execution ---
main
