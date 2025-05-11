#!/bin/bash

# Made by: Emad Adel
# GitHub: https://github.com/emadadel4

tput civis
trap "tput cnorm; clear; exit" INT TERM EXIT

# Colors
WHITESMOKE="\033[0;37m"
RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
NC="\033[0m"
YELLOW="\033[1;33m"

welcome_screen() {
    clear
    echo -e "\n           ________"
    echo -e "          \\        /"
    echo -e "           \\      /"
    echo -e "${WHITESMOKE}          Void Setup    ${NC}"
    echo -e "             \\  /"
    echo -e "              \\/"
    echo -e "${WHITESMOKE} \n       Made by Emad Adel${NC}"
}

# Menu structure
declare -A menus=(
    ["Main menu"]="Environments,Additional packages,Start install,Exit"
    ["Environments"]="KDE,XFCE,DWM"
)

# Selection state
declare -A selected

# Function mapping
declare -A actions=(
    ["KDE"]="install_kde"
    ["XFCE"]="install_xfce"
    ["DWM"]="install_dwm"
)

# Cursor index and menu stack
cursor=0
menu_stack=("Main menu")
PKGS=""

# ===== DESKTOP ENVIRONMENT FUNCTIONS =====
install_kde() {
    echo -e "\n${GREEN}Installing KDE Plasma Desktop...${NC}"
    curl -sL https://raw.githubusercontent.com/emadadel4/void-linux/refs/heads/main/scripts/env/kde/setup.sh | bash
}

install_xfce() {
    echo -e "\n${GREEN}Installing XFCE Desktop...${NC}"
    curl -sL https://raw.githubusercontent.com/emadadel4/void-linux/refs/heads/main/scripts/env/xfce/setup.sh | bash
}

install_dwm() {
    echo -e "\n${GREEN}Installing DWM...${NC}"
    curl -sL https://raw.githubusercontent.com/emadadel4/void-linux/refs/heads/main/scripts/env/dwm/setup.sh | bash
}

draw_menu() {
    clear
    welcome_screen
    local menu_name="${menu_stack[-1]}"

    IFS=',' read -ra items <<< "${menus[$menu_name]}"


    echo -e "\n${YELLOW}(Use ↑/↓, Enter to select, q or Esc to go back)${NC}\n"

    for i in "${!items[@]}"; do
        local item="${items[$i]}"
        local prefix=" "
        [[ $i -eq $cursor ]] && prefix="${YELLOW}>${NC}"

        local marker="[ ]"
        [[ "${selected[$item]}" == "true" ]] && marker="${YELLOW}[*]${NC}"

        case "$item" in
            "Start install"|"Exit"|"Additional packages"|"Environments")
                echo -e "${prefix} ${item}"
                ;;
            *)
                echo -e "${prefix} ${marker} ${item}"
                ;;
        esac
    done
}

install_selected() {
    clear
    echo -e "${CYAN}Installing selected items...${NC}"

    local has_selection=false

    for item in "${!selected[@]}"; do
        if [[ "${selected[$item]}" == "true" ]]; then
            has_selection=true
            local func="${actions[$item]}"
            if [[ -n "$func" ]]; then
                $func
            fi
        fi
    done

    if [[ -n "$PKGS" ]]; then
        echo -e "${GREEN}Installing additional packages: ${PKGS}${NC}"
        sleep 1
        sudo xbps-install -Sy $PKGS
    fi

    if [[ "$has_selection" == false && -z "$PKGS" ]]; then
        echo -e "${RED}No selections or packages provided.${NC}"
    else
        echo -e "${CYAN}Installation complete!${NC}"
    fi

    read -p "Press any key to return..."
}

handle_input() {
    read -rsn1 input
    local menu_name="${menu_stack[-1]}"
    IFS=',' read -ra items <<< "${menus[$menu_name]}"

    case "$input" in
        $'\x1b')
            read -rsn2 -t 0.1 rest
            input+="$rest"
            case "$input" in
                $'\x1b[A') ((cursor > 0)) && ((cursor--)) ;;
                $'\x1b[B') ((cursor < ${#items[@]} - 1)) && ((cursor++)) ;;
                *) 
                    [[ "${#menu_stack[@]}" -gt 1 ]] && unset 'menu_stack[-1]' && cursor=0
                    ;;
            esac
            ;;
        "q"|"Q"|"ض")
            [[ "${#menu_stack[@]}" -gt 1 ]] && unset 'menu_stack[-1]' && cursor=0
            ;;
        "") # Enter key
            local selected_item="${items[$cursor]}"
            case "$selected_item" in
                "Exit")
                    clear
                    exit 0
                    ;;
                "Start install")
                    install_selected
                    ;;
                "Additional packages")
                    read -p "Enter packages to install (separated by spaces): " PKGS
                    ;;
                "Environments")
                    menu_stack+=("Environments")
                    cursor=0
                    ;;
                *)
                    if [[ "${selected[$selected_item]}" == "true" ]]; then
                        selected[$selected_item]="false"
                    else
                        selected[$selected_item]="true"
                    fi
                    ;;
            esac
            ;;
    esac
}

while true; do
    draw_menu
    handle_input
done