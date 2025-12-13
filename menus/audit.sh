#!/bin/bash

# Colors
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

print_header() {
    clear
    echo -e "${BOLD_RED}   >>> REDHAWK SECURITY AUDIT <<<   ${NC}"
    echo -e "${RED}════════════════════════════════════════${NC}"
}

while true; do
  print_header
  echo
  echo -e "${WHITE}   [ AUDIT TOOLS ]${NC}"
  echo
  echo -e "   ${CYAN}[1]${NC} ${WHITE}Run Port Scan${NC}"
  echo -e "   ${CYAN}[2]${NC} ${WHITE}Run Vulnerability Scan${NC}"
  echo -e "   ${CYAN}[0]${NC} ${WHITE}Return to Main Menu${NC}"
  echo
  echo -e "${RED}════════════════════════════════════════${NC}"
  echo
  read -p "$(echo -e ${BOLD_RED}redhawk@audit${NC}:${BLUE}~${NC}$ )" choice

  case $choice in
    1)
      cd /opt/redhawk
      ansible-playbook playbooks/scan.yml
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