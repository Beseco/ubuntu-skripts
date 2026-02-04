#!/bin/bash
set -e

# Docker CE Installation für Ubuntu
# https://docs.docker.com/engine/install/ubuntu/

echo "🐳 Docker Installation startet..."

# Prüfen ob Docker schon installiert ist
if command -v docker &> /dev/null; then
    echo "⚠️  Docker ist bereits installiert: $(docker --version)"
    read -p "Trotzdem neu installieren? (j/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Jj]$ ]]; then
        echo "Abgebrochen."
        exit 0
    fi
fi

# System updaten
echo "📦 System wird aktualisiert..."
sudo apt-get update
sudo apt-get -y upgrade

# Abhängigkeiten installieren
echo "📦 Abhängigkeiten werden installiert..."
sudo apt-get install -y ca-certificates curl

# Docker GPG Key hinzufügen
echo "🔑 Docker GPG Key wird hinzugefügt..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Repository hinzufügen
echo "📚 Docker Repository wird hinzugefügt..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

# Docker installieren
echo "🐳 Docker wird installiert..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Aktuellen User zur docker Gruppe hinzufügen (optional)
if [ -n "$SUDO_USER" ]; then
    echo "👤 User '$SUDO_USER' wird zur docker Gruppe hinzugefügt..."
    sudo usermod -aG docker "$SUDO_USER"
    echo "ℹ️  Bitte neu einloggen damit die Gruppenänderung wirksam wird."
fi

echo ""
echo "✅ Docker erfolgreich installiert!"
docker --version
docker compose version
