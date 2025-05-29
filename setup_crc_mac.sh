#!/bin/zsh

# Script to set up OpenShift 4 using CodeReady Containers on Mac
# This script is specifically for Intel-based Macs

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed.${NC}"
        return 1
    fi
    return 0
}

# Function to check if a command succeeded
check_status() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: $1${NC}"
        exit 1
    fi
}

# Check prerequisites
print_header "Checking Prerequisites"
check_command brew || {
    echo -e "${RED}Homebrew is required. Please install it first:${NC}"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
}

# Install required tools
print_header "Installing Required Tools"
echo "Installing required packages..."
brew install qemu hyperkit
check_status "Failed to install required packages"

# Download and install CRC
print_header "Installing CodeReady Containers"
echo -e "${YELLOW}Note: CRC requires authentication to download.${NC}"
echo "Please follow these steps:"
echo "1. Visit: https://console.redhat.com/openshift/create/local"
echo "2. Log in with your Red Hat account"
echo "3. Click on 'Download the OpenShift Local binary'"
echo "4. Download 'crc-macos-installer.pkg'"
echo "5. Place the downloaded file in the current directory"
echo -e "\nPress Enter when you have downloaded the file..."
read

# Verify the downloaded file
if [ ! -f "crc-macos-installer.pkg" ]; then
    echo -e "${RED}Error: crc-macos-installer.pkg not found in current directory${NC}"
    exit 1
fi

echo "Verifying download..."
if [ ! -s crc-macos-installer.pkg ]; then
    echo -e "${RED}Error: Downloaded file is empty${NC}"
    exit 1
fi

echo "Installing CRC..."
echo -e "${YELLOW}The installer will now open. Please follow the installation steps in the GUI.${NC}"
echo "Press Enter to continue..."
read

# Open the installer
open crc-macos-installer.pkg

echo -e "\n${YELLOW}After the installation is complete, press Enter to continue with the setup...${NC}"
read

# Setup CRC
print_header "Setting up CRC"
echo "Initializing CRC..."
crc setup
check_status "Failed to setup CRC"

# Get pull secret
print_header "Pull Secret Required"
echo -e "${YELLOW}You need a pull secret from Red Hat to continue.${NC}"
echo "1. Go to https://console.redhat.com/openshift/create/local"
echo "2. Log in with your Red Hat account"
echo "3. Click on 'Download the pull secret'"
echo -e "\nAfter you have your pull secret, run:"
echo "crc start --pull-secret-file /path/to/pull-secret.txt"

# Print next steps
print_header "Next Steps"
echo -e "${GREEN}After installation:${NC}"
echo "1. Run 'crc start' to start the cluster"
echo "2. Run 'crc console' to open the web console"
echo "3. Run 'crc oc-env' to set up the oc CLI"
echo -e "\n${YELLOW}Note:${NC}"
echo "- The cluster will use approximately 8GB of RAM"
echo "- You need at least 35GB of free disk space"
echo "- The first startup may take 15-20 minutes" 