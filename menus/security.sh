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

# Get the directory where the script is located
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

print_header() {
    clear
    echo -e "${BOLD_RED}   >>> REDHAWK SECURITY SETUP <<<   ${NC}"
    echo -e "${RED}════════════════════════════════════════${NC}"
}

setup_fail2ban() {
    echo
    echo -e "${YELLOW}   🛡️  Installing & Configuring Fail2Ban...${NC}"
    (
        set -e
        apt install -y fail2ban
        cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
action = %(action_mwl)s
[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200
EOF
        systemctl start fail2ban
        systemctl enable fail2ban
    ) &
    loading $!
    echo -e "${GREEN}   ✅ Fail2Ban installed and configured!${NC}"
}

setup_clamav() {
    echo
    echo -e "${YELLOW}   🦠 Installing & Configuring ClamAV...${NC}"
    (
        set -e
        apt install -y clamav clamav-daemon clamav-freshclam
        systemctl stop clamav-freshclam || true
        freshclam || true
        systemctl start clamav-freshclam
        systemctl enable clamav-freshclam
        systemctl start clamav-daemon
        systemctl enable clamav-daemon
        cat > /etc/cron.daily/clamav-scan <<'EOF'
#!/bin/bash
SCAN_DIR="/home"
LOG_FILE="/var/log/clamav/daily-scan.log"
echo "ClamAV Scan - $(date)" >> $LOG_FILE
clamscan -r -i $SCAN_DIR >> $LOG_FILE 2>&1
EOF
        chmod +x /etc/cron.daily/clamav-scan
        mkdir -p /var/log/clamav
    ) &
    loading $!
    echo -e "${GREEN}   ✅ ClamAV installed and daily scan scheduled!${NC}"
}

setup_ufw() {
    echo
    echo -e "${YELLOW}   🔥 Configuring UFW Firewall...${NC}"
    (
        set -e
        ufw --force reset
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow ssh
        ufw allow 'Nginx Full'
        ufw --force enable
    ) &
    loading $!
    echo -e "${GREEN}   ✅ UFW Firewall configured and enabled!${NC}"
}

# Handle flag for full setup
if [[ "$1" == "--full" ]]; then
    setup_fail2ban
    setup_clamav
    setup_ufw
    exit 0
fi

while true; do
  print_header
  echo
  echo -e "${WHITE}   [ SECURITY MODULES ]${NC}"
  echo
  echo -e "   ${CYAN}[1]${NC} ${WHITE}Configure UFW Firewall${NC}"
  echo -e "   ${CYAN}[2]${NC} ${WHITE}Install Fail2Ban${NC}"
  echo -e "   ${CYAN}[3]${NC} ${WHITE}Install ClamAV Antivirus${NC}"
  echo -e "   ${CYAN}[4]${NC} ${WHITE}Run Full Security Hardening (Ansible)${NC}"
  echo -e "   ${CYAN}[0]${NC} ${WHITE}Return to Main Menu${NC}"
  echo
  echo -e "${RED}════════════════════════════════════════${NC}"
  echo
  read -p "$(echo -e ${BOLD_RED}redhawk@sec${NC}:${BLUE}~${NC}$ )" choice

  case $choice in
    1) setup_ufw ;;
    2) setup_fail2ban ;;
    3) setup_clamav ;;
    4)
      echo -e "${YELLOW}   🚀 Running Ansible Security Playbook...${NC}"
      cd "$BASE_DIR" && ansible-playbook playbooks/security.yml
      ;;
    0) break ;;
    *) echo -e "${RED}   ❌ Invalid option${NC}" ; sleep 1 ;;
  esac
  
  echo
  read -p "Press Enter to continue..."
done