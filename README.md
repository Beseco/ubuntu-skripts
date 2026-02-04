# Ubuntu Server Scripts 🐧

Eine Sammlung von Bash-Scripts für die schnelle Einrichtung von Ubuntu-Servern.

## Voraussetzungen

- Ubuntu Server 20.04 / 22.04 / 24.04
- Root-Zugriff oder sudo-Berechtigung
- Internetverbindung

## Scripts

### 🐳 install-docker.sh

Installiert Docker CE (Community Edition) mit allen offiziellen Komponenten.

**Was wird installiert:**
- Docker CE
- Docker CLI
- containerd.io
- Docker Buildx Plugin
- Docker Compose Plugin

**Verwendung:**
```bash
wget https://raw.githubusercontent.com/Beseco/ubuntu-skripts/main/install-docker.sh
chmod +x install-docker.sh
sudo ./install-docker.sh
```

---

### 🖥️ portainer.sh

Richtet Portainer CE ein – eine Web-UI zur Verwaltung von Docker-Containern.

**Was passiert:**
- Erstellt ein Docker Volume für Portainer-Daten
- Startet Portainer auf Port 9443 (HTTPS) und 8000 (Edge Agent)
- Container startet automatisch nach Reboot

**Verwendung:**
```bash
wget https://raw.githubusercontent.com/Beseco/ubuntu-skripts/main/portainer.sh
chmod +x portainer.sh
sudo ./portainer.sh
```

**Nach der Installation:**
Öffne `https://DEINE-SERVER-IP:9443` im Browser und erstelle einen Admin-Account.

---

## Schnellstart

Alles auf einmal installieren:

```bash
# Docker installieren
wget -qO- https://raw.githubusercontent.com/Beseco/ubuntu-skripts/main/install-docker.sh | sudo bash

# Portainer starten
wget -qO- https://raw.githubusercontent.com/Beseco/ubuntu-skripts/main/portainer.sh | sudo bash
```

## Lizenz

MIT – Mach damit was du willst! 🚀
