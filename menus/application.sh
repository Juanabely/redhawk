#!/bin/bash

# Colors (Defined here in case it's run standalone)
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Get the directory where the script is located
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ASCII Art Logo (Mini)
print_header() {
    clear
    echo -e "${BOLD_RED}   >>> REDHAWK APPLICATION SETUP <<<   ${NC}"
    echo -e "${RED}═══════════════════════════════════════════${NC}"
}

# Installation Functions
install_docker() {
    echo
    echo -e "${YELLOW}   🐳 Installing Docker & Docker Compose...${NC}"
    
    # Run logic from user script
    (
        set -e
        apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt update -qq
        apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        systemctl start docker
        systemctl enable docker
        if [ "$SUDO_USER" ]; then usermod -aG docker $SUDO_USER; fi
    ) &
    loading $!
    echo -e "${GREEN}   ✅ Docker installed successfully!${NC}"
}

install_nginx() {
    echo
    echo -e "${YELLOW}   🌐 Installing & Configuring Nginx...${NC}"
    (
        set -e
        apt install -y nginx
        cat > /etc/nginx/nginx.conf <<'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
events { worker_connections 2048; multi_accept on; }
http {
    sendfile on; tcp_nopush on; tcp_nodelay on; keepalive_timeout 65; types_hash_max_size 2048; server_tokens off;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    client_max_body_size 20M;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    gzip on;
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF
        systemctl start nginx
        systemctl enable nginx
    ) &
    loading $!
    echo -e "${GREEN}   ✅ Nginx installed with security hardening!${NC}"
}

# Handle flag for full setup
if [[ "$1" == "--full" ]]; then
    install_docker
    install_nginx
    exit 0
fi

while true; do
  print_header
  echo
  echo -e "${WHITE}   [ AVAILABLE MODULES ]${NC}"
  echo
  echo -e "   ${CYAN}[1]${NC} ${WHITE}Install Docker & Compose${NC}"
  echo -e "   ${CYAN}[2]${NC} ${WHITE}Install Secure Nginx${NC}"
  echo -e "   ${CYAN}[3]${NC} ${WHITE}Install Proxy Manager (Ansible)${NC}"
  echo -e "   ${CYAN}[4]${NC} ${WHITE}Install Traefik (Ansible)${NC}"
  echo -e "   ${CYAN}[0]${NC} ${WHITE}Return to Main Menu${NC}"
  echo
  echo -e "${RED}═══════════════════════════════════════════${NC}"
  echo
  read -p "$(echo -e ${BOLD_RED}redhawk@apps${NC}:${BLUE}~${NC}$ )" choice

  case $choice in
    1) install_docker ;;
    2) install_nginx ;;
    3)
      echo -e "${YELLOW}   🚀 Running Ansible Playbook for NPM...${NC}"
      cd "$BASE_DIR" && ansible-playbook playbooks/apps.yml --tags npm
      ;;
    4)
      echo -e "${YELLOW}   🚀 Running Ansible Playbook for Traefik...${NC}"
      cd "$BASE_DIR" && ansible-playbook playbooks/apps.yml --tags traefik
      ;;
    0) break ;;
    *) echo -e "${RED}   ❌ Invalid option${NC}" ; sleep 1 ;;
  esac
  
  echo
  read -p "Press Enter to continue..."
done