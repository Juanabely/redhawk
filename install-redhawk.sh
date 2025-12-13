#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

clear
print_logo
echo -e "${YELLOW}   🚀 Initializing Redhawk Installer...${NC}"
echo

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}   ❌ Please run as root or with sudo${NC}"
  exit 1
fi

echo -e "${YELLOW}   🔍 Checking system compatibility...${NC}"

# Detect OS
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  echo -e "${RED}   ❌ Cannot detect OS${NC}"
  exit 1
fi

if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
  echo -e "${RED}   ❌ Only Ubuntu/Debian supported${NC}"
  exit 1
fi

echo -e "${GREEN}   ✓ OS Detected: $PRETTY_NAME${NC}"
echo

echo -e "${YELLOW}   📦 Installing dependencies...${NC}"
apt update -qq &
loading $!
apt install -y git ansible python3-pip sshpass > /dev/null 2>&1 &
loading $!

INSTALL_DIR="/opt/redhawk"

if [ -d "$INSTALL_DIR" ]; then
  echo -e "${YELLOW}   🔁 Updating Redhawk...${NC}"
  cd "$INSTALL_DIR" && git pull -q &
  loading $!
else
  echo -e "${YELLOW}   📥 Cloning Redhawk...${NC}"
  git clone -q https://github.com/juanabely/redhawk.git "$INSTALL_DIR" &
  loading $!
fi

chmod +x "$INSTALL_DIR/redhawk.sh"
chmod +x "$INSTALL_DIR/menus/"*.sh

ln -sf "$INSTALL_DIR/redhawk.sh" /usr/local/bin/redhawk

echo
echo -e "${GREEN}   ✅ Redhawk installed successfully${NC}"
echo -e "${GREEN}   👉 Run: ${BOLD_RED}redhawk${NC}"
echo