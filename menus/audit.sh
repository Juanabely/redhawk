#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

while true; do
  clear
  echo "================================"
  echo "🔍 SECURITY AUDIT"
  echo "================================"
  echo
  echo "[1] Scan Open Ports"
  echo "[2] Vulnerability Scan (with Risk Score)"
  echo "[3] Full Security Audit"
  echo "[0] Back"
  echo
  read -p "$(echo -e ${YELLOW}Select:${NC} )" audit

  case $audit in
    1)
     cd /opt/redhawk && ansible-playbook playbooks/scan.yml --tags port_scan
     ;;
    2)
     cd /opt/redhawk && ansible-playbook playbooks/scan.yml --tags vuln_scan
     ;
    3)
     cd /opt/redhawk && ansible-playbook playbooks/scan.yml
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