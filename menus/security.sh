#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

while true; do
  clear
  echo "================================"
  echo "🔒 SECURITY SETUP"
  echo "================================"
  echo
  echo "[1] Setup UFW Firewall"
  echo "[2] Install ClamAV Antivirus"
  echo "[3] SSH Hardening"
  echo "[4] Full Security Hardening"
  echo "[0] Back"
  echo
  read -p "$(echo -e ${YELLOW}Select:${NC} )" sec

  case $sec in
    1)
      cd /opt/redhawk
      ansible-playbook /opt/redhawk/playbooks/security.yml --tags ufw
      ;;
    2)
      cd /opt/redhawk
      ansible-playbook /opt/redhawk/playbooks/security.yml --tags clamav
      ;;
    3)
      cd /opt/redhawk
      ansible-playbook /opt/redhawk/playbooks/security.yml --tags ssh
      ;;
    4)
      cd /opt/redhawk
      ansible-playbook /opt/redhawk/playbooks/security.yml
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