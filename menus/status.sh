#!/bin/bash

# Robust path detection
SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || realpath "${BASH_SOURCE[0]}")
DIR_PATH=$(dirname "$SCRIPT_PATH")
BASE_DIR=$(dirname "$DIR_PATH")

# Source shared utilities
if [ -f "$BASE_DIR/utils.sh" ]; then
    source "$BASE_DIR/utils.sh"
else
    RED='\033[0;31m'; BOLD_RED='\033[1;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; NC='\033[0m'
fi

MAGENTA='\033[0;35m'
BOLD_WHITE='\033[1;37m'

print_header() {
    clear
    echo -e "${BOLD_RED}   >>> REDHAWK SYSTEM STATUS <<<   ${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════${NC}"
}

divider() {
    echo -e "${RED}───────────────────────────────────────────────────${NC}"
}

# ── System Overview ──────────────────────────────────
show_system_overview() {
    echo
    echo -e "${CYAN}  ⚙  SYSTEM OVERVIEW${NC}"
    divider

    # Hostname & Uptime
    local hostname
    hostname=$(hostname)
    local uptime_str
    uptime_str=$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | cut -d',' -f1-2)
    echo -e "   ${WHITE}Hostname  :${NC} ${GREEN}$hostname${NC}"
    echo -e "   ${WHITE}Uptime    :${NC} ${GREEN}$uptime_str${NC}"

    # OS
    local os_info
    os_info=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
    echo -e "   ${WHITE}OS        :${NC} ${GREEN}$os_info${NC}"

    # Current time
    echo -e "   ${WHITE}Time      :${NC} ${GREEN}$(date '+%Y-%m-%d %H:%M:%S %Z')${NC}"
}

# ── Resource Usage ───────────────────────────────────
show_resources() {
    echo
    echo -e "${CYAN}  📊 RESOURCE USAGE${NC}"
    divider

    # CPU load
    local load
    load=$(awk '{print $1, $2, $3}' /proc/loadavg)
    echo -e "   ${WHITE}CPU Load  :${NC} ${YELLOW}$load${NC} (1m / 5m / 15m)"

    # RAM
    local total used free
    total=$(free -m | awk '/^Mem:/{print $2}')
    used=$(free -m  | awk '/^Mem:/{print $3}')
    free=$(free -m  | awk '/^Mem:/{print $4}')
    local pct=$(( used * 100 / total ))
    local bar_used=$(( pct / 5 ))
    local bar_free=$(( 20 - bar_used ))
    local bar="${GREEN}$(printf '█%.0s' $(seq 1 $bar_used 2>/dev/null))${RED}$(printf '░%.0s' $(seq 1 $bar_free 2>/dev/null))${NC}"
    echo -e "   ${WHITE}RAM       :${NC} ${used}MB / ${total}MB (${pct}%) $bar"

    # Disk
    echo
    echo -e "   ${WHITE}Disk Usage:${NC}"
    df -h --output=target,size,used,avail,pcent 2>/dev/null | grep -E '^(/|/home|/var|/opt)' | \
        while IFS= read -r line; do
            local mount size used avail pct
            mount=$(echo "$line" | awk '{print $1}')
            size=$(echo "$line"  | awk '{print $2}')
            used=$(echo "$line"  | awk '{print $3}')
            avail=$(echo "$line" | awk '{print $4}')
            pct=$(echo "$line"   | awk '{print $5}')
            echo -e "     ${CYAN}$mount${NC}  size:${WHITE}$size${NC}  used:${YELLOW}$used${NC}  free:${GREEN}$avail${NC}  (${pct})"
        done
}

# ── Service Status ───────────────────────────────────
show_services() {
    echo
    echo -e "${CYAN}  🔧 SERVICE STATUS${NC}"
    divider

    local services=("ssh" "nginx" "ufw" "fail2ban" "clamav-daemon" "docker")
    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            echo -e "   ${GREEN}●${NC} ${WHITE}$svc${NC}  ${GREEN}[running]${NC}"
        elif systemctl list-unit-files --quiet "$svc.service" 2>/dev/null | grep -q "$svc"; then
            echo -e "   ${RED}●${NC} ${WHITE}$svc${NC}  ${RED}[stopped]${NC}"
        else
            echo -e "   ${YELLOW}●${NC} ${WHITE}$svc${NC}  ${YELLOW}[not installed]${NC}"
        fi
    done
}

# ── UFW Firewall ─────────────────────────────────────
show_firewall() {
    echo
    echo -e "${CYAN}  🔥 FIREWALL (UFW)${NC}"
    divider

    if command -v ufw &>/dev/null; then
        local ufw_status
        ufw_status=$(ufw status 2>/dev/null | head -1)
        if echo "$ufw_status" | grep -qi "active"; then
            echo -e "   ${GREEN}●${NC} UFW is ${GREEN}active${NC}"
            echo
            ufw status numbered 2>/dev/null | grep --color=never "^\[" | \
                while IFS= read -r line; do
                    echo -e "   ${CYAN}$line${NC}"
                done
        else
            echo -e "   ${RED}●${NC} UFW is ${RED}inactive${NC}"
        fi
    else
        echo -e "   ${YELLOW}   UFW not installed${NC}"
    fi
}

# ── Docker Containers ────────────────────────────────
show_docker() {
    echo
    echo -e "${CYAN}  🐳 DOCKER CONTAINERS${NC}"
    divider

    if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
        local containers
        containers=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null)
        if [ -n "$containers" ]; then
            echo "$containers" | while IFS= read -r line; do
                echo -e "   ${WHITE}$line${NC}"
            done
        else
            echo -e "   ${YELLOW}   No running containers${NC}"
        fi

        local stopped
        stopped=$(docker ps -a --filter "status=exited" --format "{{.Names}}" 2>/dev/null | wc -l)
        [ "$stopped" -gt 0 ] && echo -e "\n   ${RED}   $stopped stopped container(s)${NC}"
    else
        echo -e "   ${YELLOW}   Docker not installed or not running${NC}"
    fi
}

# ── Recent Failed SSH Logins ─────────────────────────
show_ssh_activity() {
    echo
    echo -e "${CYAN}  🔑 RECENT FAILED SSH LOGINS (last 10)${NC}"
    divider

    if [ -f /var/log/auth.log ]; then
        local failed
        failed=$(grep "Failed password" /var/log/auth.log 2>/dev/null | tail -10)
        if [ -n "$failed" ]; then
            echo "$failed" | while IFS= read -r line; do
                echo -e "   ${RED}$line${NC}"
            done
        else
            echo -e "   ${GREEN}   No recent failed login attempts${NC}"
        fi
    else
        echo -e "   ${YELLOW}   Auth log not available${NC}"
    fi
}

# ── Menu ─────────────────────────────────────────────
while true; do
    print_header
    echo
    echo -e "${WHITE}   [ STATUS MODULES ]${NC}"
    echo
    echo -e "   ${CYAN}[1]${NC} ${WHITE}Full System Status${NC}       ${RED}::${NC} ${YELLOW}All sections below${NC}"
    echo -e "   ${CYAN}[2]${NC} ${WHITE}System Overview${NC}           ${RED}::${NC} ${YELLOW}Host, uptime, OS${NC}"
    echo -e "   ${CYAN}[3]${NC} ${WHITE}Resource Usage${NC}            ${RED}::${NC} ${YELLOW}CPU, RAM, Disk${NC}"
    echo -e "   ${CYAN}[4]${NC} ${WHITE}Service Status${NC}            ${RED}::${NC} ${YELLOW}nginx, docker, fail2ban...${NC}"
    echo -e "   ${CYAN}[5]${NC} ${WHITE}Firewall Rules${NC}            ${RED}::${NC} ${YELLOW}UFW active rules${NC}"
    echo -e "   ${CYAN}[6]${NC} ${WHITE}Docker Containers${NC}         ${RED}::${NC} ${YELLOW}Running containers${NC}"
    echo -e "   ${CYAN}[7]${NC} ${WHITE}SSH Activity${NC}              ${RED}::${NC} ${YELLOW}Recent failed logins${NC}"
    echo -e "   ${CYAN}[0]${NC} ${WHITE}Return to Main Menu${NC}"
    echo
    echo -e "${RED}═══════════════════════════════════════════════════${NC}"
    echo
    read -p "$(echo -e ${BOLD_RED}redhawk@status${NC}:${BLUE}~${NC}$ )" choice

    case $choice in
        1)
            print_header
            show_system_overview
            show_resources
            show_services
            show_firewall
            show_docker
            show_ssh_activity
            ;;
        2)
            print_header
            show_system_overview
            ;;
        3)
            print_header
            show_resources
            ;;
        4)
            print_header
            show_services
            ;;
        5)
            print_header
            show_firewall
            ;;
        6)
            print_header
            show_docker
            ;;
        7)
            print_header
            show_ssh_activity
            ;;
        0) break ;;
        *) echo -e "${RED}   ❌ Invalid option${NC}"; sleep 1; continue ;;
    esac

    echo
    read -p "Press Enter to continue..."
done
