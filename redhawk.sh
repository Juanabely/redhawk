#!/bin/bash

# Robust path detection
SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || realpath "${BASH_SOURCE[0]}")
BASE_DIR=$(dirname "$SCRIPT_PATH")

# Source shared utilities (Colors, Loading)
if [ -f "$BASE_DIR/utils.sh" ]; then
    source "$BASE_DIR/utils.sh"
else
    # Fallback colors if utils.sh is missing
    RED='\033[0;31m'; BOLD_RED='\033[1;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; NC='\033[0m'
fi

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
export -f print_logo

while true; do
  clear
  print_logo
  echo
  echo -e "${WHITE}   [ MENU SELECTION ]${NC}"
  echo
  echo -e "   ${CYAN}[1]${NC} ${WHITE}Application Setup${NC}    ${RED}::${NC} ${YELLOW}Docker, Nginx, Proxy Tools${NC}"
  echo -e "   ${CYAN}[2]${NC} ${WHITE}Security Setup${NC}       ${RED}::${NC} ${YELLOW}Firewall, Fail2Ban, AntiVirus${NC}"
  echo -e "   ${CYAN}[3]${NC} ${WHITE}Security Audit${NC}       ${RED}::${NC} ${YELLOW}Port Scan, Vuln Scan${NC}"
  echo -e "   ${CYAN}[4]${NC} ${WHITE}Full Production Setup${NC} ${RED}::${NC} ${YELLOW}One-click Deploy All${NC}"
  echo -e "   ${CYAN}[0]${NC} ${WHITE}Exit${NC}"
  echo
  echo -e "${RED}═════════════════════════════════════${NC}"
  echo
  read -p "$(echo -e ${BOLD_RED}root@redhawk${NC}:${BLUE}~${NC}$ )" choice

  case $choice in
    1) bash "$BASE_DIR/menus/application.sh" ;;
    2) bash "$BASE_DIR/menus/security.sh" ;;
    3) bash "$BASE_DIR/menus/audit.sh" ;;
    4) 
      echo
      echo -e "${YELLOW}   🚀 Starting Full Production Setup...${NC}"
      # Run Docker, Nginx, Fail2Ban, ClamAV
      bash "$BASE_DIR/menus/application.sh" --full
      bash "$BASE_DIR/menus/security.sh" --full
      echo -e "${GREEN}   ✅ Full Production Setup Complete!${NC}"
      read -p "Press Enter to return to menu..."
      ;;
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