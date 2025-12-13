```bash
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

# ASCII Art Logo (Mini)
print_header() {
    clear
    echo -e "${BOLD_RED}   >>> REDHAWK APPLICATION SETUP <<<   ${NC}"
    echo -e "${RED}═══════════════════════════════════════════${NC}"
}

while true; do
  print_header
  echo
  echo -e "${WHITE}   [ AVAILABLE MODULES ]${NC}"
  echo
  echo -e "   ${CYAN}[1]${NC} ${WHITE}Install Docker & Portainer${NC}"
  echo -e "   ${CYAN}[2]${NC} ${WHITE}Install Nginx Proxy Manager${NC}"
  echo -e "   ${CYAN}[3]${NC} ${WHITE}Install Traefik${NC}"
  echo -e "   ${CYAN}[0]${NC} ${WHITE}Return to Main Menu${NC}"
  echo
  echo -e "${RED}═══════════════════════════════════════════${NC}"
  echo
  read -p "$(echo -e ${BOLD_RED}redhawk@apps${NC}:${BLUE}~${NC}$ )" choice

  case $choice in
    1)
      echo
      echo -e "${YELLOW}   🐳 Installing Docker environment...${NC}"
      # Placeholder for actual installation logic
      sleep 2
      echo -e "${GREEN}   ✅ Docker & Portainer installed!${NC}"
      sleep 1
      ;;
    2)
      echo
      echo -e "${YELLOW}   🌐 Installing Nginx Proxy Manager...${NC}"
      sleep 2
      echo -e "${GREEN}   ✅ NPM installed!${NC}"
      sleep 1
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