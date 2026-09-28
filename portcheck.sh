#!/data/data/com.termux/files/usr/bin/bash

VERSION="1.3.1"
APP_NAME="PortCheck"

GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
RESET='\033[0m'

banner() {
    clear
    echo
    echo -e "${CYAN}╭────────────────────────────────────────╮${RESET}"
    echo -e "${CYAN}│${RESET}       🟨☀️🟥  ${BRIGHT_CYAN}P O R T C H E C K${RESET}       ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                 ${YELLOW}v$VERSION${RESET}                 ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}          ${WHITE}Termux Port Utility${RESET}           ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                        ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}          ${GREEN}by TaQaNa${RESET}  •  ${CYAN}GitHub${RESET}          ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}       ${WHITE}github.com/Alone0010/PortCheck${RESET}   ${CYAN}│${RESET}"
    echo -e "${CYAN}╰────────────────────────────────────────╯${RESET}"
    echo
}

check_port() {
    read -rp "Target (IP/Hostname): " TARGET
    read -rp "Port: " PORT

    if [[ -z "$TARGET" || -z "$PORT" ]]; then
        echo -e "${RED}[ERROR] Target and Port are required.${RESET}"
        read -rp "Press ENTER..."
        return
    fi

    if ! [[ "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then
        echo -e "${RED}[ERROR] Invalid port.${RESET}"
        read -rp "Press ENTER..."
        return
    fi

    echo
    echo -e "${YELLOW}[*] Checking $TARGET:$PORT ...${RESET}"
    echo

    START=$(date +%s%N)

    timeout 1 bash -c "</dev/tcp/$TARGET/$PORT" 2>/dev/null
    RESULT=$?

    END=$(date +%s%N)
    TIME_MS=$(( (END - START) / 1000000 ))

    if [[ "$RESULT" -eq 0 ]]; then
        STATE="OPEN"
        STATE_COLOR="$GREEN"
    elif [[ "$RESULT" -eq 124 ]]; then
        STATE="TIMEOUT"
        STATE_COLOR="$YELLOW"
    else
        STATE="CLOSED"
        STATE_COLOR="$RED"
    fi

    echo -e "${CYAN}╭────────────────────────────────────────╮${RESET}"
    echo -e "${CYAN}│${RESET}              ${BRIGHT_CYAN}PORT RESULT${RESET}              ${CYAN}│${RESET}"
    echo -e "${CYAN}├────────────────────────────────────────┤${RESET}"
    echo -e "${CYAN}│${RESET} Target : ${WHITE}$TARGET${RESET}"
    echo -e "${CYAN}│${RESET} Port   : ${WHITE}$PORT${RESET}"
    echo -e "${CYAN}│${RESET}                                        ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}              ${STATE_COLOR}● $STATE${RESET}              ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                        ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET} Response Time : ${WHITE}${TIME_MS}ms${RESET}"
    echo -e "${CYAN}╰────────────────────────────────────────╯${RESET}"
    save_history "Check Port | $TARGET:$PORT | $STATE | ${TIME_MS}ms"
    echo
    read -rp "Press ENTER to continue..."
}

common_ports() {
    read -rp "Target (IP/Hostname): " TARGET

    if [[ -z "$TARGET" ]]; then
        echo -e "${RED}[ERROR] Target is required.${RESET}"
        read -rp "Press ENTER..."
        return
    fi

    echo
    echo -e "${CYAN}╭────────────────────────────────────────╮${RESET}"
    echo -e "${CYAN}│${RESET}             ${BRIGHT_CYAN}COMMON PORTS${RESET}             ${CYAN}│${RESET}"
    echo -e "${CYAN}├────────────────────────────────────────┤${RESET}"
    echo -e "${CYAN}│${RESET} Target : ${WHITE}$TARGET${RESET}"
    echo -e "${CYAN}╰────────────────────────────────────────╯${RESET}"
    echo
    printf "%-8s %-12s %-10s\n" "PORT" "STATE" "TIME"
    echo "────────────────────────────────"
    for PORT in 21 22 23 25 53 80 110 143 443 8080; do

        START=$(date +%s%N)

        timeout 1 bash -c "</dev/tcp/$TARGET/$PORT" 2>/dev/null
        RESULT=$?

        END=$(date +%s%N)
        TIME_MS=$(( (END - START) / 1000000 ))

        if [[ "$RESULT" -eq 0 ]]; then
            STATE="OPEN"
            printf "%-8s ${GREEN}%-12s${RESET} %-10s\n" "$PORT" "$STATE" "${TIME_MS}ms"
        elif [[ "$RESULT" -eq 124 ]]; then
            STATE="TIMEOUT"
            printf "%-8s ${YELLOW}%-12s${RESET} %-10s\n" "$PORT" "$STATE" "${TIME_MS}ms"
        else
            STATE="CLOSED"
            printf "%-8s ${RED}%-12s${RESET} %-10s\n" "$PORT" "$STATE" "${TIME_MS}ms"
        fi
    done

    echo
    echo -e "${CYAN}────────────────────────────────────────${RESET}"
    echo -e "${GREEN}● OPEN${RESET}  ${YELLOW}● TIMEOUT${RESET}  ${RED}● CLOSED${RESET}"
    echo -e "${CYAN}────────────────────────────────────────${RESET}"
    echo
    read -rp "Press ENTER to continue..."
}

range_scan() {
    read -rp "Target (IP/Hostname): " TARGET
    read -rp "Start Port: " START_PORT
    read -rp "End Port: " END_PORT

    if [[ -z "$TARGET" || -z "$START_PORT" || -z "$END_PORT" ]]; then
        echo -e "${RED}[ERROR] All fields are required.${RESET}"
        read -rp "Press ENTER..."
        return
    fi

    if ! [[ "$START_PORT" =~ ^[0-9]+$ ]] || \
       ! [[ "$END_PORT" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}[ERROR] Ports must be numbers.${RESET}"
        read -rp "Press ENTER..."
        return
    fi

    if (( START_PORT < 1 || START_PORT > 65535 ||
          END_PORT < 1 || END_PORT > 65535 )); then
        echo -e "${RED}[ERROR] Port must be between 1 and 65535.${RESET}"
        read -rp "Press ENTER..."
        return
    fi

    if (( START_PORT > END_PORT )); then
        echo -e "${RED}[ERROR] Start Port must be <= End Port.${RESET}"
        read -rp "Press ENTER..."
        return
    fi

    echo
    echo -e "${CYAN}╭────────────────────────────────────────╮${RESET}"
    echo -e "${CYAN}│${RESET}              ${BRIGHT_CYAN}PORT RANGE${RESET}              ${CYAN}│${RESET}"
    echo -e "${CYAN}├────────────────────────────────────────┤${RESET}"
    echo -e "${CYAN}│${RESET} Target : ${WHITE}$TARGET${RESET}"
    echo -e "${CYAN}│${RESET} Range  : ${WHITE}$START_PORT - $END_PORT${RESET}"
    echo -e "${CYAN}╰────────────────────────────────────────╯${RESET}"
    echo
    echo -e "${YELLOW}[*] Scanning...${RESET}"
    echo

    printf "%-8s %-12s %-10s\n" "PORT" "STATE" "TIME"
    echo "────────────────────────────────"

    OPEN_COUNT=0
    CLOSED_COUNT=0
    TIMEOUT_COUNT=0

    for (( PORT=START_PORT; PORT<=END_PORT; PORT++ )); do

        START=$(date +%s%N)

        timeout 1 bash -c "</dev/tcp/$TARGET/$PORT" 2>/dev/null
        RESULT=$?

        END=$(date +%s%N)
        TIME_MS=$(( (END - START) / 1000000 ))

        if [[ "$RESULT" -eq 0 ]]; then
            STATE="OPEN"
            ((OPEN_COUNT++))

            printf "%-8s ${GREEN}● %-10s${RESET} %-10s\n" "$PORT" "$STATE" "${TIME_MS}ms"

        elif [[ "$RESULT" -eq 124 ]]; then
            STATE="TIMEOUT"
            ((TIMEOUT_COUNT++))

            printf "%-8s ${YELLOW}● %-10s${RESET} %-10s\n" "$PORT" "$STATE" "${TIME_MS}ms"

        else
            STATE="CLOSED"
            ((CLOSED_COUNT++))

            printf "%-8s ${RED}● %-10s${RESET} %-10s\n" "$PORT" "$STATE" "${TIME_MS}ms"
        fi
    done

    echo
    echo -e "${CYAN}────────────────────────────────────────${RESET}"
    echo -e "${GREEN} OPEN : $OPEN_COUNT${RESET}   ${RED}CLOSED : $CLOSED_COUNT${RESET}   ${YELLOW}TIMEOUT : $TIMEOUT_COUNT${RESET}"
    echo -e "${CYAN}────────────────────────────────────────${RESET}"
    echo -e "${GREEN}✓ Scan completed.${RESET}"
    echo
    read -rp "Press ENTER to continue..."
}

fast_scan() {
    read -rp "Target (IP/Hostname): " TARGET
    read -rp "Start Port: " START_PORT
    read -rp "End Port: " END_PORT

    if [[ -z "$TARGET" || -z "$START_PORT" || -z "$END_PORT" ]]; then
        echo -e "${RED}[ERROR] All fields are required.${RESET}"
        read -rp "Press ENTER..."
        return
    fi

    if ! [[ "$START_PORT" =~ ^[0-9]+$ ]] || ! [[ "$END_PORT" =~ ^[0-9]+$ ]] || (( START_PORT < 1 || END_PORT > 65535 || START_PORT > END_PORT )); then
        echo -e "${RED}[ERROR] Invalid port range.${RESET}"
        read -rp "Press ENTER..."
        return
    fi

    echo
    echo -e "${CYAN}╭────────────────────────────────────────╮${RESET}"
    echo -e "${CYAN}│${RESET}               ${BRIGHT_CYAN}FAST SCAN${RESET}               ${CYAN}│${RESET}"
    echo -e "${CYAN}├────────────────────────────────────────┤${RESET}"
    echo -e "${CYAN}│${RESET} Target : ${WHITE}$TARGET${RESET}"
    echo -e "${CYAN}│${RESET} Range  : ${WHITE}$START_PORT - $END_PORT${RESET}"
    echo -e "${CYAN}╰────────────────────────────────────────╯${RESET}"
    echo

    SCAN_START=$(date +%s%N)
    OPEN_COUNT=0

    echo -e "${YELLOW}[*] Fast scanning...${RESET}"
    echo

    for ((PORT=START_PORT; PORT<=END_PORT; PORT++)); do
        (
            if timeout 1 bash -c "</dev/tcp/$TARGET/$PORT" 2>/dev/null; then
                echo -e "${GREEN}● OPEN${RESET}  Port $PORT"
            fi
        ) &
    done

    wait

    SCAN_END=$(date +%s%N)
    SCAN_TIME=$(( (SCAN_END - SCAN_START) / 1000000 ))

    echo
    echo -e "${CYAN}────────────────────────────────────────${RESET}"
    echo -e "${GREEN}✓ Fast scan completed.${RESET}"
    echo -e "${CYAN}Scan time :${RESET} ${WHITE}${SCAN_TIME}ms${RESET}"
    echo -e "${CYAN}────────────────────────────────────────${RESET}"

    save_history "Fast Scan | $TARGET:$START_PORT-$END_PORT | Time: ${SCAN_TIME}ms"

    echo
    read -rp "Press ENTER to continue..."
}

show_history() {
    HISTORY_FILE="$HOME/.portcheck/history/scans.log"
    echo
    echo "SCAN HISTORY"
    echo "────────────────────────────────"
    if [ ! -s "$HISTORY_FILE" ]; then
        echo "No scan history yet."
    else
        tail -20 "$HISTORY_FILE"
    fi
    echo "────────────────────────────────"
    read -rp "Press ENTER to continue..."
}

save_history() {
    HISTORY_FILE="$HOME/.portcheck/history/scans.log"
    mkdir -p "$(dirname "$HISTORY_FILE")"
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $1" >> "$HISTORY_FILE"
}

clear_history() {
    HISTORY_FILE="$HOME/.portcheck/history/scans.log"
    > "$HISTORY_FILE"
    echo "[OK] Scan history cleared."
    read -rp "Press ENTER to continue..."
}

main_menu() {
    while true; do
        banner

        echo -e "${CYAN}╭────────────────────────────────────────╮${RESET}"
        echo -e "${CYAN}│${RESET}              ${BRIGHT_CYAN}MAIN MENU${RESET}              ${CYAN}│${RESET}"
        echo -e "${CYAN}├────────────────────────────────────────┤${RESET}"
        echo -e "${CYAN}│${RESET}  ${YELLOW}1${RESET}  Check Port                       ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}  ${YELLOW}2${RESET}  Common Ports                     ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}  ${YELLOW}3${RESET}  Port Range                       ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}  ${YELLOW}4${RESET}  Fast Scan                        ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}  ${YELLOW}5${RESET}  Scan History                     ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}  ${YELLOW}6${RESET}  Clear History                    ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}  ${RED}0${RESET}  Exit                             ${CYAN}│${RESET}"
        echo -e "${CYAN}╰────────────────────────────────────────╯${RESET}"
        echo
        read -rp "  Select an option: " CHOICE
        case "$CHOICE" in
            1) check_port ;;
            2) common_ports ;;
            3) range_scan ;;
            4) fast_scan ;;
            5) show_history ;;
            6) clear_history ;;
            0)
                clear
                echo "Goodbye."
                exit 0
                ;;
            *)
                echo -e "${RED}[ERROR] Invalid option.${RESET}"
                sleep 1
                ;;
        esac
    done
}

main_menu
