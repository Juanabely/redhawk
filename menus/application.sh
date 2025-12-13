#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

while true; do
  clear
  echo "================================"
  echo "📦 APPLICATION SETUP"
  echo "================================"
  echo
  echo "[1] Docker"
  echo "[2] Docker Compose"
  echo "[3] Portainer"
  echo "[4] Nginx Proxy Manager"
  echo "[5] Traefik"
  echo "[6] Uptime Kuma"
  echo "[7] Install All"
  echo "[0] Back"
  echo
  read -p "$(echo -e ${YELLOW}Select:${NC} )" app

  case $app in
    1)
      cd /opt/redhawk
      ansible-playbook /opt/redhawk/playbooks/apps.yml --tags docker
      ;;
    2)
      cd /opt/redhawk
      ansible-playbook /opt/redhawk/playbooks/apps.yml --tags docker_compose
      ;;
    3)
      cd /opt/redhawk
      ansible-playbook /opt/redhawk/playbooks/apps.yml --tags portainer
      ;;
    4)
      cd /opt/redhawk
      ansible-playbook /opt/redhawk/playbooks/apps.yml --tags npm
      ;;
    5)
      cd /opt/redhawk
      ansible-playbook /opt/redhawk/playbooks/apps.yml --tags traefik
      ;;
    6)
      cd /opt/redhawk
      ansible-playbook /opt/redhawk/playbooks/apps.yml --tags uptime_kuma
      ;;
    7)
      cd /opt/redhawk
      ansible-playbook /opt/redhawk/playbooks/apps.yml
      ;;
    0)
      break
      ;;
    *)
      echo -e "${RED}❌ Invalid option${NC}"
      ;;
  esac
  
  echo
  read -p "Press Enter to continue..."
done