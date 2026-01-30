#!/bin/bash
set -e

echo "System Maintenance & Cleanup Script"

# Check for sudo privileges upfront
sudo -v

# 1. System Updates

echo "---  Updating System Packages ---"
sudo apt update
sudo apt full-upgrade -y

# 2. Fix Broken Installs

echo "---  Fixing Broken Dependencies ---"
sudo apt --fix-broken install -y

# 3. Cleanup Unused Packages

echo "---  Removing Unused Packages ---"
sudo apt autoremove -y
sudo apt autoclean

# 4. Clean Package Cache
# Removes .deb files for packages that are no longer installed
sudo apt clean

# 5. Docker Cleanup (if installed)
if command -v docker &> /dev/null; then
    echo ""
    echo "---  Cleaning Docker System ---"
    # Removes stopped containers, unused networks, dangling images, and build cache
    # -f forces it without confirmation prompt
    sudo docker system prune -f
    
    # Optional: Remove unused volumes (uncomment if aggressive cleanup is desired)
    # sudo docker volume prune -f
    echo "Docker cleanup complete."
fi

# 6. NPM Cache Cleanup (if installed)
# We check if npm is available in the current path.
# Note: If NVM is used, this script might need to source bashrc or run as the user.
if command -v npm &> /dev/null; then
    echo ""
    echo "---  Verifying NPM Cache ---"
    npm cache verify
fi

# 7. Systemd Journal Cleanup

echo "---  Vacuuming System Logs ---"
# Keep only the last 2 weeks of logs to save space
sudo journalctl --vacuum-time=2weeks

# 8. Thumbnail Cache

echo "--- Clearing User Thumbnail Cache ---"
rm -rf ~/.cache/thumbnails/*


echo " Maintenance Complete! System is updated and cleaned."
