#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

while true; do
  clear
  echo -e "${RED}════════════════════════════════${NC}"
  echo -e "${RED}     🔥  REDHAWK v1.0  🔥${NC}"
  echo -e "${RED}════════════════════════════════${NC}"
  echo
  echo -e "${BLUE}[1]${NC} Application Setup (Docker/Portainer/NPM/Traefik)"
  echo -e "${BLUE}[2]${NC} Security Setup (Firewall/AV/SSH Hardening)"
  echo -e "${BLUE}[3]${NC} Security Audit (Port Scan/Vuln Scan)"
  echo -e "${BLUE}[0]${NC} Exit"
  echo
  read -p "$(echo -e ${YELLOW}Select option:${NC} )" choice

  case $choice in
    1) /opt/redhawk/menus/application.sh ;;
    2) /opt/redhawk/menus/security.sh ;;
    3) /opt/redhawk/menus/audit.sh ;;
    0) 
      echo -e "${GREEN}👋 Goodbye!${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}❌ Invalid option${NC}"
      sleep 2
      ;;
  esac
done