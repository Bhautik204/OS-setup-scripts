#!/bin/bash
set -e

echo " QA Setup Script for Standard User"
echo "Target Tools: VS Code, Google Chrome, Postman"

# Check for sudo privileges upfront
sudo -v

# Core dependencies
echo "--- Updating repositories and installing prerequisites ---"
sudo apt update
sudo apt install -y curl wget gpg software-properties-common apt-transport-https

# 1. VS Code
echo "--- Installing VS Code ---"
# Import the Microsoft GPG key
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
# Enable the VS Code repository
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

sudo apt update
sudo apt install -y code

# 2. Google Chrome
echo "--- Installing Google Chrome ---"
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

# 3. Postman
echo "--- Installing Postman ---"
# Clean previous installs if any
if [ -d "/opt/Postman" ]; then
    sudo rm -rf /opt/Postman
fi

# Download to temporary location
wget -q https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
# Extract to /opt
sudo tar -xzf postman.tar.gz -C /opt
rm postman.tar.gz
# Create symbolic link
sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman

# Create Desktop Entry for Postman (User-friendly convenience)
mkdir -p ~/.local/share/applications
cat <<EOF > ~/.local/share/applications/postman.desktop
[Desktop Entry]
Name=Postman
GenericName=API Client
Exec=/opt/Postman/Postman
Terminal=false
Type=Application
Icon=/opt/Postman/app/resources/app/assets/icon.png
Categories=Development;
EOF

echo " QA Environment Setup Complete! Please reboot to ensure all changes take effect."
