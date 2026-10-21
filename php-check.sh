#!/usr/bin/env bash
# php-check.sh – lokal ausführen: sudo bash php-check.sh

CVES="CVE-2026-109618|CVE-2026-109619"

check() {
  v="${1%%[-+~]*}"; mm="${v%.*}"; p="${v##*.}"
  case "$mm" in
    8.5) min=12;; 8.4) min=27;; 8.3) min=36;; 8.2) min=35;;
    *) echo "KEIN FIX (EOL) - Upgrade noetig"; return;;
  esac
  [ "$p" -ge "$min" ] 2>/dev/null && echo "OK" || echo "VERWUNDBAR"
}

getver() {  # gibt nur eine gueltige Versionsnummer aus, sonst nichts
  out=$("$@" php -r 'echo PHP_VERSION;' 2>/dev/null) || return
  [[ "$out" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]] && echo "${BASH_REMATCH[0]}"
}

echo "=== $(hostname) ==="

# 1) PHP auf dem Host
v=$(getver env)
if [ -n "$v" ]; then
  s=$(check "$v")
  if [ "$s" = "VERWUNDBAR" ] && command -v dpkg >/dev/null 2>&1; then
    pkg=$(dpkg -S "$(readlink -f "$(command -v php)")" 2>/dev/null | cut -d: -f1)
    if [ -n "$pkg" ] && zcat /usr/share/doc/"$pkg"/changelog.Debian.gz 2>/dev/null | grep -qE "$CVES"; then
      s="OK (Backport der Distribution)"
    fi
  fi
  echo "Host:      PHP $v -> $s"
else
  echo "Host:      kein PHP"
fi

# 2) Laufende Docker-Container
if command -v docker >/dev/null 2>&1; then
  docker ps --format '{{.Names}}' | while read -r c; do
    v=$(getver docker exec "$c")
    if [ -n "$v" ]; then
      echo "Container: $c  PHP $v -> $(check "$v")"
    else
      echo "Container: $c  (kein PHP)"
    fi
  done
fi
