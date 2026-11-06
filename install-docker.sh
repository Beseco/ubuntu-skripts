#!/bin/bash
set -e

# Docker CE Installation für Ubuntu und Debian
# https://docs.docker.com/engine/install/ubuntu/
# https://docs.docker.com/engine/install/debian/

echo "🐳 Docker Installation startet..."

# Root oder sudo? (Debian-Minimalinstallationen haben oft kein sudo)
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
elif command -v sudo &> /dev/null; then
    SUDO="sudo"
else
    echo "❌ Weder root noch sudo verfügbar. Bitte als root ausführen."
    exit 1
fi

# Distribution erkennen
. /etc/os-release
case "$ID" in
    ubuntu)
        DISTRO="ubuntu"
        CODENAME="$VERSION_CODENAME"
        ;;
    debian)
        DISTRO="debian"
        CODENAME="$VERSION_CODENAME"
        ;;
    *)
        # Ableger wie Linux Mint oder Pop!_OS über ID_LIKE erkennen
        if [[ "$ID_LIKE" == *ubuntu* ]]; then
            DISTRO="ubuntu"
            CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"
        elif [[ "$ID_LIKE" == *debian* ]]; then
            DISTRO="debian"
            CODENAME="${DEBIAN_CODENAME:-$VERSION_CODENAME}"
        else
            echo "❌ Nicht unterstützte Distribution: $ID"
            exit 1
        fi
        ;;
esac

if [ -z "$CODENAME" ]; then
    echo "❌ Codename der Distribution konnte nicht ermittelt werden."
    exit 1
fi

echo "ℹ️  Erkannt: $PRETTY_NAME → Docker-Repo: $DISTRO/$CODENAME"

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
$SUDO apt-get update
$SUDO apt-get -y upgrade

# Konflikt-Pakete aus den Distributions-Repos entfernen (falls vorhanden)
echo "🧹 Alte/konfliktierende Docker-Pakete werden entfernt..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    if dpkg -l "$pkg" 2>/dev/null | grep -q '^ii'; then
        $SUDO apt-get remove -y "$pkg"
    fi
done

# Abhängigkeiten installieren
echo "📦 Abhängigkeiten werden installiert..."
$SUDO apt-get install -y ca-certificates curl

# Docker GPG Key hinzufügen
echo "🔑 Docker GPG Key wird hinzugefügt..."
$SUDO install -m 0755 -d /etc/apt/keyrings
$SUDO curl -fsSL "https://download.docker.com/linux/${DISTRO}/gpg" -o /etc/apt/keyrings/docker.asc
$SUDO chmod a+r /etc/apt/keyrings/docker.asc

# Repository hinzufügen
echo "📚 Docker Repository wird hinzugefügt..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${DISTRO} \
  ${CODENAME} stable" | \
  $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null

$SUDO apt-get update

# Docker installieren
echo "🐳 Docker wird installiert..."
$SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Aktuellen User zur docker Gruppe hinzufügen (optional)
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    echo "👤 User '$SUDO_USER' wird zur docker Gruppe hinzugefügt..."
    $SUDO usermod -aG docker "$SUDO_USER"
    echo "ℹ️  Bitte neu einloggen damit die Gruppenänderung wirksam wird."
fi

echo ""
echo "✅ Docker erfolgreich installiert!"
docker --version
docker compose version
