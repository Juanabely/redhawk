#!/bin/bash

# Robust path detection
SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || realpath "${BASH_SOURCE[0]}")
DIR_PATH=$(dirname "$SCRIPT_PATH")
BASE_DIR=$(dirname "$DIR_PATH")

# Source shared utilities (Colors, Loading)
if [ -f "$BASE_DIR/utils.sh" ]; then
    source "$BASE_DIR/utils.sh"
else
    # Fallback if utils.sh is not found
    RED='\033[0;31m'; BOLD_RED='\033[1;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; NC='\033[0m'
fi

print_header() {
    clear
    echo -e "${BOLD_RED}   >>> REDHAWK SSH SETUP & HARDENING <<<   ${NC}"
    echo -e "${RED}═════════════════════════════════════════════${NC}"
}

setup_user() {
    echo
    read -p "   👤 Enter username: " target_user
    if id "$target_user" >/dev/null 2>&1; then
        echo -e "${GREEN}   ✅ User '$target_user' already exists.${NC}"
    else
        echo -e "${YELLOW}   ➕ Creating user '$target_user'...${NC}"
        useradd -m -s /bin/bash "$target_user"
        echo -e "${GREEN}   ✅ User created.${NC}"
    fi

    echo
    read -p "   🔑 Give sudo privileges? (y/n): " give_sudo
    if [[ "$give_sudo" == "y" ]]; then
        usermod -aG sudo "$target_user"
        echo -e "${GREEN}   ✅ Added to sudo group.${NC}"
    fi

    echo
    echo -e "${YELLOW}   📝 Paste your public SSH key below:${NC}"
    read -r public_key
    
    if [[ -n "$public_key" ]]; then
        user_home=$(eval echo ~$target_user)
        mkdir -p "$user_home/.ssh"
        echo "$public_key" >> "$user_home/.ssh/authorized_keys"
        chown -R "$target_user:$target_user" "$user_home/.ssh"
        chmod 700 "$user_home/.ssh"
        chmod 600 "$user_home/.ssh/authorized_keys"
        echo -e "${GREEN}   ✅ SSH key deployed.${NC}"
    else
        echo -e "${RED}   ⚠️  No key provided. Skipping key deployment.${NC}"
    fi
}

harden_ssh() {
    echo
    echo -e "${YELLOW}   🛡️  Starting SSH Hardening...${NC}"
    
    # Safety Check: Are there other users with sudo?
    sudo_users=$(grep -Po '^sudo:.*:\K.*' /etc/group | tr ',' ' ')
    if [[ -z "$sudo_users" ]]; then
        echo -e "${RED}   ❌ ERROR: No non-root sudo users detected.${NC}"
        echo -e "${RED}      Aborting hardening to prevent lockout!${NC}"
        return 1
    fi

    echo -e "${CYAN}   >>> Disabling Password Authentication...${NC}"
    sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    
    echo -e "${CYAN}   >>> Disabling Root Login...${NC}"
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    
    echo -e "${YELLOW}   🔄 Restarting SSH Service...${NC}"
    systemctl restart sshd
    echo -e "${GREEN}   ✅ SSH Hardening Complete!${NC}"
}

while true; do
  print_header
  echo
  echo -e "${WHITE}   [ SSH MANAGEMENT ]${NC}"
  echo
  echo -e "   ${CYAN}[1]${NC} ${WHITE}Configure User & SSH Key${NC}"
  echo -e "   ${CYAN}[2]${NC} ${WHITE}Apply Security Hardening${NC}  ${RED}(Root/Pass Disable)${NC}"
  echo -e "   ${CYAN}[0]${NC} ${WHITE}Return to Main Menu${NC}"
  echo
  echo -e "${RED}═════════════════════════════════════════════${NC}"
  echo
  read -p "$(echo -e ${BOLD_RED}redhawk@ssh${NC}:${BLUE}~${NC}$ )" choice

  case $choice in
    1) setup_user ;;
    2) harden_ssh ;;
    0) break ;;
    *) echo -e "${RED}   ❌ Invalid option${NC}" ; sleep 1 ;;
  esac
  
  echo
  read -p "Press Enter to continue..."
done
