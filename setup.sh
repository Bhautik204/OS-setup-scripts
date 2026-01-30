#!/bin/bash
set -e

echo " Developer workstation setup started"

sudo apt update

# Ensure we have the basic transport/CA packages for repositories
sudo apt install -y curl wget gpg software-properties-common apt-transport-https

# ---------- Base tools ----------
sudo apt install -y \
  curl wget git unzip ca-certificates \
  software-properties-common \
  apt-transport-https

# ---------- Java 17 ----------
sudo apt install -y openjdk-17-jdk maven

# ---------- Spring Boot ----------
# (Handled via Maven)
mvn -version

# ---------- Docker ----------
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# ---------- PostgreSQL ----------
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql

# ---------- pgAdmin ----------
curl -fsSL https://www.pgadmin.org/static/packages_pgadmin_org.pub \
| sudo gpg --dearmor -o /usr/share/keyrings/pgadmin.gpg

echo "deb [signed-by=/usr/share/keyrings/pgadmin.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" \
| sudo tee /etc/apt/sources.list.d/pgadmin4.list

sudo apt update
sudo apt install -y pgadmin4-desktop

# ---------- Chrome ----------
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

# ---------- VS Code ----------
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

sudo apt update
sudo apt install -y code

# ---------- Sublime Text ----------
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg \
| sudo gpg --dearmor -o /usr/share/keyrings/sublime.gpg

echo "deb [signed-by=/usr/share/keyrings/sublime.gpg] https://download.sublimetext.com/ apt/stable/" \
| sudo tee /etc/apt/sources.list.d/sublime.list

sudo apt update
sudo apt install -y sublime-text

# ---------- Postman ----------
# Clean previous installs if any
if [ -d "/opt/Postman" ]; then
    sudo rm -rf /opt/Postman
fi

wget -q https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
sudo tar -xzf postman.tar.gz -C /opt
rm postman.tar.gz
sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman

# Create Desktop Entry for Postman
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

# ---------- Eclipse ----------
# Remove previous installations to avoid conflicts
if [ -d "/opt/eclipse" ]; then
    sudo rm -rf /opt/eclipse
fi
if [ -d "/opt/eclipse-installer" ]; then
    sudo rm -rf /opt/eclipse-installer
fi

cd /opt
# Download Eclipse IDE for Enterprise Java and Web Developers
sudo wget https://ftp2.osuosl.org/pub/eclipse/technology/epp/downloads/release/2023-12/R/eclipse-jee-2023-12-R-linux-gtk-x86_64.tar.gz -O eclipse.tar.gz
sudo tar -xzf eclipse.tar.gz
sudo rm eclipse.tar.gz
# The tarball extracts to 'eclipse' folder automatically
sudo ln -sf /opt/eclipse/eclipse /usr/local/bin/eclipse

# Create Desktop Entry for Eclipse
mkdir -p ~/.local/share/applications
cat <<EOF > ~/.local/share/applications/eclipse.desktop
[Desktop Entry]
Name=Eclipse IDE
Type=Application
Exec=/opt/eclipse/eclipse
Icon=/opt/eclipse/icon.xpm
Comment=Integrated Development Environment
NoDisplay=false
Categories=Development;IDE;
Name[en]=Eclipse IDE
EOF

# ---------- NVM ----------
export NVM_DIR="$HOME/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Immediately source nvm to use it in this script
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Add to bashrc only if not present (idempotent)
if ! grep -q "export NVM_DIR=\"\$HOME/.nvm\"" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.bashrc
fi

# Now we can use nvm
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

echo " Setup complete. Reboot recommended."
