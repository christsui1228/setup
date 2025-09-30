#!/bin/bash

# ==============================================================================
# Script Name:   install_ca_certificates.sh
# Description:   Updates APT package lists and installs the ca-certificates
#                package to enable proper HTTPS support.
# Author:        Your Name
# Date:          2025-09-30
# ==============================================================================

# Exit immediately if any command fails
set -e

# --- Permission Check ---
# Check if the script is being run with root privileges (via sudo)
if [ "$(id -u)" -ne 0 ]; then
   echo "Error: This script must be run as root. Please use 'sudo'." >&2
   exit 1
fi

# --- Main Logic ---
echo "--> Step 1/2: Updating package lists..."
apt-get update

echo
echo "--> Step 2/2: Installing ca-certificates package..."
# The -y flag automatically answers "yes" to the installation prompt
apt-get install -y ca-certificates

echo
echo "✅ Done. The ca-certificates package was installed successfully."
