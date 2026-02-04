#!/bin/bash
set -e

# Portainer CE Installation
# https://docs.portainer.io/start/install-ce/server/docker/linux

echo "🖥️  Portainer Installation startet..."

# Prüfen ob Docker läuft
if ! command -v docker &> /dev/null; then
    echo "❌ Docker ist nicht installiert. Bitte zuerst install-docker.sh ausführen."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker Daemon läuft nicht. Bitte Docker starten."
    exit 1
fi

# Prüfen ob Portainer schon läuft
if docker ps -a --format '{{.Names}}' | grep -q "^portainer$"; then
    echo "⚠️  Portainer Container existiert bereits."
    read -p "Container löschen und neu erstellen? (j/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Jj]$ ]]; then
        echo "🗑️  Alter Container wird entfernt..."
        docker stop portainer 2>/dev/null || true
        docker rm portainer 2>/dev/null || true
    else
        echo "Abgebrochen."
        exit 0
    fi
fi

# Volume erstellen (falls nicht vorhanden)
echo "💾 Portainer Volume wird erstellt..."
docker volume create portainer_data 2>/dev/null || true

# Portainer starten
echo "🚀 Portainer wird gestartet..."
docker run -d \
    -p 8000:8000 \
    -p 9443:9443 \
    --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

# IP-Adresse ermitteln
SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "✅ Portainer erfolgreich installiert!"
echo ""
echo "🌐 Öffne im Browser: https://${SERVER_IP}:9443"
echo "   (Beim ersten Aufruf Admin-Account erstellen)"
