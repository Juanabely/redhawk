#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "================================"
echo "🔥 REDHAWK INSTALLER"
echo "================================"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run as root or with sudo${NC}"
  exit 1
fi

echo -e "${YELLOW}🔍 Checking system...${NC}"

# Detect OS
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  echo -e "${RED}❌ Cannot detect OS${NC}"
  exit 1
fi

if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
  echo -e "${RED}❌ Only Ubuntu/Debian supported${NC}"
  exit 1
fi

echo -e "${GREEN}✓ OS: $PRETTY_NAME${NC}"

echo -e "${YELLOW}📦 Installing dependencies...${NC}"
apt update -qq
apt install -y git ansible python3-pip sshpass > /dev/null 2>&1

INSTALL_DIR="/opt/redhawk"

if [ -d "$INSTALL_DIR" ]; then
  echo -e "${YELLOW}🔁 Updating Redhawk...${NC}"
  cd "$INSTALL_DIR" && git pull -q
else
  echo -e "${YELLOW}📥 Cloning Redhawk...${NC}"
  git clone -q https://github.com/juanabely/redhawk.git "$INSTALL_DIR"
fi

chmod +x "$INSTALL_DIR/redhawk.sh"
chmod +x "$INSTALL_DIR/menus/"*.sh

ln -sf "$INSTALL_DIR/redhawk.sh" /usr/local/bin/redhawk

echo
echo -e "${GREEN}✅ Redhawk installed successfully${NC}"
echo -e "${GREEN}👉 Run: ${YELLOW}redhawk${NC}"