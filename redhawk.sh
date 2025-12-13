#!/bin/bash

# Colors
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ASCII Art Logo
print_logo() {
    echo -e "${BOLD_RED}"
    echo "      . --- .      "
    echo "    /        \     "
    echo "   |  O  _  O |    "
    echo "   |  ./   \. |    "
    echo "   /  \`-._.-'  \   "
    echo " .' /         \ '. "
    echo "    | REDHAWK |    "
    echo "    '._     _.'    "
    echo "       \`- -'       "
    echo -e "${NC}"
    echo -e "${BOLD_RED}   >>> SERVER DEFENSE SYSTEM <<<   ${NC}"
    echo -e "${RED}═════════════════════════════════════${NC}"
}

# Loading Animation
loading() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

while true; do
  clear
  print_logo
  echo
  echo -e "${WHITE}   [ MENU SELECTION ]${NC}"
  echo
  echo -e "   ${CYAN}[1]${NC} ${WHITE}Application Setup${NC}    ${RED}::${NC} ${YELLOW}Docker, Portainer, NPM, Traefik${NC}"
  echo -e "   ${CYAN}[2]${NC} ${WHITE}Security Setup${NC}       ${RED}::${NC} ${YELLOW}Firewall, AV, SSH Hardening${NC}"
  echo -e "   ${CYAN}[3]${NC} ${WHITE}Security Audit${NC}       ${RED}::${NC} ${YELLOW}Port Scan, Vuln Scan${NC}"
  echo -e "   ${CYAN}[0]${NC} ${WHITE}Exit${NC}"
  echo
  echo -e "${RED}═════════════════════════════════════${NC}"
  echo
  read -p "$(echo -e ${BOLD_RED}root@redhawk${NC}:${BLUE}~${NC}$ )" choice

  case $choice in
    1) /opt/redhawk/menus/application.sh ;;
    2) /opt/redhawk/menus/security.sh ;;
    3) /opt/redhawk/menus/audit.sh ;;
    0) 
      echo
      echo -e "${GREEN}   👋 Shutting down Redhawk systems...${NC}"
      sleep 1
      exit 0
      ;;
    *)
      echo
      echo -e "${RED}   ❌ Invalid option selected${NC}"
      sleep 1
      ;;
  esac
done