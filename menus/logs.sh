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

LINES=${LINES_TO_SHOW:-50}   # default tail lines; override with: LINES_TO_SHOW=100 redhawk

print_header() {
    clear
    echo -e "${BOLD_RED}   >>> REDHAWK LOG VIEWER <<<   ${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════${NC}"
}

divider() {
    echo -e "${RED}───────────────────────────────────────────────────${NC}"
}

# Helper: print a log file with a title
view_log() {
    local title="$1"
    local logfile="$2"
    local grep_filter="${3:-}"   # optional grep pattern to highlight

    print_header
    echo
    echo -e "${CYAN}  📄 $title${NC}"
    divider

    if [ ! -f "$logfile" ]; then
        echo -e "   ${YELLOW}   Log file not found: $logfile${NC}"
    else
        echo -e "   ${WHITE}Showing last $LINES lines of ${CYAN}$logfile${NC}"
        echo
        if [ -n "$grep_filter" ]; then
            tail -n "$LINES" "$logfile" 2>/dev/null | grep --color=never -i "$grep_filter" | \
                sed "s/.*/${RED}&${NC}/" || true
            echo
            echo -e "   ${YELLOW}ℹ  Filter applied: ${WHITE}\"$grep_filter\"${NC}"
        else
            tail -n "$LINES" "$logfile" 2>/dev/null | \
                sed -E "s/(error|fail|invalid|refused|denied)/$(printf '\033[0;31m')\1$(printf '\033[0m')/gI" | \
                sed -E "s/(warn|warning)/$(printf '\033[1;33m')\1$(printf '\033[0m')/gI" | \
                sed -E "s/(success|accepted|started|enabled)/$(printf '\033[0;32m')\1$(printf '\033[0m')/gI"
        fi
    fi
}

# ── Auth Log ─────────────────────────────────────────
view_auth_log() {
    view_log "AUTH LOG — SSH / Login Activity" "/var/log/auth.log"
    echo
    echo -e "${CYAN}  🔑 SUMMARY${NC}"
    divider
    local total_fail total_accept banned
    total_fail=$(grep -c "Failed password" /var/log/auth.log 2>/dev/null || echo 0)
    total_accept=$(grep -c "Accepted " /var/log/auth.log 2>/dev/null || echo 0)
    echo -e "   ${WHITE}Failed login attempts :${NC} ${RED}$total_fail${NC}"
    echo -e "   ${WHITE}Successful logins     :${NC} ${GREEN}$total_accept${NC}"

    # Top attacking IPs
    echo
    echo -e "   ${WHITE}Top attacking IPs:${NC}"
    grep "Failed password" /var/log/auth.log 2>/dev/null | \
        grep -oP 'from \K[\d.]+' | sort | uniq -c | sort -rn | head -5 | \
        while read count ip; do
            echo -e "     ${RED}$ip${NC}  →  ${YELLOW}$count attempts${NC}"
        done
}

# ── Fail2Ban Log ─────────────────────────────────────
view_fail2ban_log() {
    local logfile="/var/log/fail2ban.log"
    view_log "FAIL2BAN LOG — Blocked IPs" "$logfile"
    echo
    echo -e "${CYAN}  🛡  SUMMARY${NC}"
    divider
    local bans unban
    bans=$(grep -c "Ban " "$logfile" 2>/dev/null || echo 0)
    unban=$(grep -c "Unban " "$logfile" 2>/dev/null || echo 0)
    echo -e "   ${WHITE}Total bans  :${NC} ${RED}$bans${NC}"
    echo -e "   ${WHITE}Total unbans:${NC} ${GREEN}$unban${NC}"
    echo
    echo -e "   ${WHITE}Currently banned IPs:${NC}"
    if command -v fail2ban-client &>/dev/null && systemctl is-active --quiet fail2ban; then
        fail2ban-client status sshd 2>/dev/null | grep "Banned IP" | \
            sed "s/Banned IP list://" | tr ' ' '\n' | grep -v '^$' | \
            while read ip; do
                echo -e "     ${RED}$ip${NC}"
            done || echo -e "   ${YELLOW}   (none)${NC}"
    else
        echo -e "   ${YELLOW}   fail2ban not running${NC}"
    fi
}

# ── Nginx Access Log ──────────────────────────────────
view_nginx_access() {
    view_log "NGINX ACCESS LOG" "/var/log/nginx/access.log"
    echo
    echo -e "${CYAN}  🌐 SUMMARY${NC}"
    divider
    local total_req errors
    total_req=$(wc -l < /var/log/nginx/access.log 2>/dev/null || echo 0)
    errors=$(grep -cE '" [45][0-9]{2} ' /var/log/nginx/access.log 2>/dev/null || echo 0)
    echo -e "   ${WHITE}Total requests :${NC} ${GREEN}$total_req${NC}"
    echo -e "   ${WHITE}4xx/5xx errors :${NC} ${RED}$errors${NC}"
    echo
    echo -e "   ${WHITE}Top 5 IPs:${NC}"
    awk '{print $1}' /var/log/nginx/access.log 2>/dev/null | sort | uniq -c | sort -rn | head -5 | \
        while read count ip; do
            echo -e "     ${CYAN}$ip${NC}  →  ${YELLOW}$count requests${NC}"
        done
}

# ── Nginx Error Log ───────────────────────────────────
view_nginx_error() {
    view_log "NGINX ERROR LOG" "/var/log/nginx/error.log"
}

# ── ClamAV Scan Log ───────────────────────────────────
view_clamav_log() {
    local logfile="/var/log/clamav/daily-scan.log"
    view_log "CLAMAV DAILY SCAN LOG" "$logfile"
    echo
    echo -e "${CYAN}  🦠 SUMMARY${NC}"
    divider
    if [ -f "$logfile" ]; then
        local infected
        infected=$(grep -c "FOUND" "$logfile" 2>/dev/null || echo 0)
        local last_scan
        last_scan=$(grep "ClamAV Scan -" "$logfile" 2>/dev/null | tail -1)
        echo -e "   ${WHITE}Last scan      :${NC} ${GREEN}$last_scan${NC}"
        echo -e "   ${WHITE}Threats found  :${NC} ${infected:+${RED}}${infected}${NC}"
    else
        echo -e "   ${YELLOW}   No ClamAV scan log found. Has a daily scan run yet?${NC}"
    fi
}

# ── Docker Logs ───────────────────────────────────────
view_docker_logs() {
    print_header
    echo
    echo -e "${CYAN}  🐳 DOCKER CONTAINER LOGS${NC}"
    divider

    if ! command -v docker &>/dev/null || ! docker info &>/dev/null 2>&1; then
        echo -e "   ${YELLOW}   Docker not installed or not running${NC}"
        return
    fi

    local containers
    mapfile -t containers < <(docker ps --format "{{.Names}}" 2>/dev/null)

    if [ ${#containers[@]} -eq 0 ]; then
        echo -e "   ${YELLOW}   No running containers${NC}"
        return
    fi

    echo -e "   ${WHITE}Running containers:${NC}"
    local i=1
    for name in "${containers[@]}"; do
        echo -e "   ${CYAN}[$i]${NC} ${WHITE}$name${NC}"
        ((i++))
    done
    echo
    read -p "   Select container (1-${#containers[@]}): " sel
    local idx=$(( sel - 1 ))
    if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$idx" -ge 0 ] && [ "$idx" -lt ${#containers[@]} ]; then
        local chosen="${containers[$idx]}"
        echo
        echo -e "${CYAN}  📄 Logs for: ${WHITE}$chosen${NC}  (last $LINES lines)"
        divider
        docker logs --tail "$LINES" "$chosen" 2>&1 | \
            sed -E "s/(error|fatal)/$(printf '\033[0;31m')\1$(printf '\033[0m')/gI" | \
            sed -E "s/(warn|warning)/$(printf '\033[1;33m')\1$(printf '\033[0m')/gI"
    else
        echo -e "${RED}   ❌ Invalid selection${NC}"
    fi
}

# ── Menu ─────────────────────────────────────────────
while true; do
    print_header
    echo
    echo -e "${WHITE}   [ LOG SOURCES ]${NC}  ${YELLOW}(showing last $LINES lines each)${NC}"
    echo
    echo -e "   ${CYAN}[1]${NC} ${WHITE}Auth Log${NC}            ${RED}::${NC} ${YELLOW}SSH logins / failures + attacking IP summary${NC}"
    echo -e "   ${CYAN}[2]${NC} ${WHITE}Fail2Ban Log${NC}        ${RED}::${NC} ${YELLOW}Blocked IPs & ban history${NC}"
    echo -e "   ${CYAN}[3]${NC} ${WHITE}Nginx Access Log${NC}    ${RED}::${NC} ${YELLOW}HTTP requests + top IPs${NC}"
    echo -e "   ${CYAN}[4]${NC} ${WHITE}Nginx Error Log${NC}     ${RED}::${NC} ${YELLOW}Web server errors${NC}"
    echo -e "   ${CYAN}[5]${NC} ${WHITE}ClamAV Scan Log${NC}     ${RED}::${NC} ${YELLOW}Daily antivirus scan results${NC}"
    echo -e "   ${CYAN}[6]${NC} ${WHITE}Docker Logs${NC}         ${RED}::${NC} ${YELLOW}Logs from a running container${NC}"
    echo -e "   ${CYAN}[0]${NC} ${WHITE}Return to Main Menu${NC}"
    echo
    echo -e "${RED}═══════════════════════════════════════════════════${NC}"
    echo
    read -p "$(echo -e ${BOLD_RED}redhawk@logs${NC}:${BLUE}~${NC}$ )" choice

    case $choice in
        1) view_auth_log ;;
        2) view_fail2ban_log ;;
        3) view_nginx_access ;;
        4) view_nginx_error ;;
        5) view_clamav_log ;;
        6) view_docker_logs ;;
        0) break ;;
        *) echo -e "${RED}   ❌ Invalid option${NC}"; sleep 1; continue ;;
    esac

    echo
    read -p "Press Enter to continue..."
done
