#!/bin/bash
set -e

echo "🔧 Developer workstation setup started"

sudo apt update

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

# ---------- Sublime Text ----------
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg \
| sudo gpg --dearmor -o /usr/share/keyrings/sublime.gpg

echo "deb [signed-by=/usr/share/keyrings/sublime.gpg] https://download.sublimetext.com/ apt/stable/" \
| sudo tee /etc/apt/sources.list.d/sublime.list

sudo apt update
sudo apt install -y sublime-text

# ---------- Postman ----------
cd /opt
sudo wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
sudo tar -xzf postman.tar.gz
sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman

# ---------- Eclipse ----------
cd /opt
sudo wget https://ftp.osuosl.org/pub/eclipse/oomph/epp/2023-12/R/eclipse-inst-jre-linux64.tar.gz
sudo tar -xzf eclipse-inst-jre-linux64.tar.gz
sudo mv eclipse-installer eclipse
sudo ln -sf /opt/eclipse/eclipse-inst /usr/local/bin/eclipse

# ---------- NVM ----------
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc

source ~/.bashrc
nvm install --lts

echo "✅ Setup complete. Reboot recommended."
