#!/bin/bash

# Made by: Emad Adel
# GitHub: https://github.com/emadadel4

# ===== COLORS =====
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ===== REMOTE PACKAGE LIST =====
PKG_URL="https://raw.githubusercontent.com/emadadel4/void/main/packages/pkg.json"



welcome_screen() {
    clear
    echo -e "\n           ________"
    echo -e "          \\        /"
    echo -e "           \\      /"
    echo -e "${YELLOW}          Void Setup    ${NC}"
    echo -e "             \\  /"
    echo -e "              \\/"
    echo -e "${GREEN} \n       Made by Emad Adel${NC}"
    echo -e "\nPress any key to continue..."
    read -rsn1
}


# ===== MENU STRUCTURE =====
declare -A menu=(
    ["Main menu"]="Desktop environment,Packages,Install selections,Exit"
    ["Desktop environment"]="KDE,XFCE,DWM,Back"
)

# Fetch packages from GitHub and add to menu
fetch_packages() {

    echo -e "${YELLOW}Loading package list...${NC}"
    if ! packages_json=$(curl -s "$PKG_URL"); then
        echo -e "${RED}Failed to fetch packages! Using default list.${NC}"
        menu["Packages"]="firefox,vlc,kitty,Back"
        return 1
    fi

    # Extract package names from the JSON manually using sed, awk, etc.
    package_list=$(echo "$packages_json" | \
                   sed 's/\[//g' | \
                   sed 's/\]//g' | \
                   sed 's/"//g' | \
                   sed 's/,/\n/g' | \
                   awk '!/^ *$/ {print $1}' | \
                   tr '\n' ',' | \
                   sed 's/,$//')

    if [ -z "$package_list" ]; then
        echo -e "${RED}Invalid package data! Using default list.${NC}"
        menu["Packages"]="firefox,vlc,kitty,Back"
        return 1
    fi

    menu["Packages"]="${package_list},Back"
    echo -e "${GREEN}Package list updated!${NC}"
    return 0

}

declare -A selected
current_menu="Main menu"
cursor=0

# ===== DESKTOP ENVIRONMENT FUNCTIONS =====
install_kde() {
    echo -e "\n${GREEN}Installing KDE Plasma Desktop...${NC}"
    curl -sL https://raw.githubusercontent.com/emadadel4/void/main/kde/setup.sh | bash
}

install_xfce() {
    echo -e "\n${GREEN}Installing XFCE Desktop...${NC}"
    curl -sL https://raw.githubusercontent.com/emadadel4/void/main/xfce/setup.sh | bash
}

install_dwm() {
    echo -e "\n${GREEN}Installing DWM...${NC}"
    curl -sL https://raw.githubusercontent.com/emadadel4/void/main/dwm/setup.sh | bash
}

# ===== PACKAGE INSTALLATION =====
install_packages() {
    local packages=("$@")
    echo -e "\n${GREEN}Installing packages: ${packages[*]}${NC}"
    sudo xbps-install -Sy "${packages[@]}"
}

# ===== DRAW MENU =====
draw_menu() {
    clear
    echo -e "${YELLOW}=== ${current_menu} ===${NC}"
    echo "---------------------"
    
    IFS=',' read -ra items <<< "${menu[$current_menu]}"
    
    for ((i=0; i<${#items[@]}; i++)); do
        item=${items[$i]}
        
        # Highlight current selection
        if [[ $i -eq $cursor ]]; then
            echo -en "${GREEN}➤ ${NC}"
        else
            echo -en "  "
        fi
        
        # Only show checkboxes for non-main menu and non-back items
        if [[ "$current_menu" != "Main menu" && "$item" != "Back" && "$item" != "Install selections" ]]; then
            if [[ "${selected[$item]}" == "true" ]]; then
                echo -e "[*] $item"
            else
                echo -e "[ ] $item"
            fi
        else
            echo -e "$item"
        fi
    done
    
    echo -e "\n${YELLOW} ↑/↓: Navigate  | Enter/Space: Select | Q: Return"
}

# ===== PROCESS SELECTION =====
process_selection() {
    IFS=',' read -ra items <<< "${menu[$current_menu]}"
    selected_item=${items[$cursor]}
    
    if [[ "$selected_item" == "Back" ]]; then
        go_back
    elif [[ "$selected_item" == "Exit" ]]; then
        clear
        exit 0
    elif [[ "$selected_item" == "Install selections" ]]; then
        install_selected
    elif [[ "$selected_item" == "Packages" ]]; then
        # Load packages only when entering Packages menu
        if [[ $packages_loaded -eq 0 ]]; then
            fetch_packages
        fi
        current_menu=$selected_item
        cursor=0
    elif [[ -n "${menu[$selected_item]}" ]]; then
        # Enter submenu
        current_menu=$selected_item
        cursor=0
    elif [[ "$current_menu" != "Main menu" ]]; then
        # Toggle selection
        if [[ "${selected[$selected_item]}" == "true" ]]; then
            selected[$selected_item]="false"
        else
            selected[$selected_item]="true"
        fi
    fi
}

# ===== INSTALL SELECTED ITEMS =====
install_selected() {
    clear
    echo -e "${YELLOW}=== INSTALLING SELECTIONS ===${NC}"
    echo "---------------------"
    
    # Install Desktop Environments first
    for item in "${!selected[@]}"; do
        if [[ "${selected[$item]}" == "true" ]]; then
            case "$item" in
                "KDE") install_kde ;;
                "XFCE") install_xfce ;;
                "GNOME") install_dwm ;;
            esac
        fi
    done
    
    # Then install regular packages
    packages=()
    for item in "${!selected[@]}"; do
        if [[ "${selected[$item]}" == "true" && ! "$item" =~ ^(KDE|XFCE|GNOME)$ ]]; then
            packages+=("$item")
        fi
    done
    
    if [[ ${#packages[@]} -gt 0 ]]; then
        install_packages "${packages[@]}"
    fi
    
    # Reset all selections
    for item in "${!selected[@]}"; do
        selected[$item]="false"
    done
    
    echo -e "\n${GREEN}Installation complete!${NC}"
    sleep 2
}

# ===== GO BACK =====
go_back() {
    if [[ "$current_menu" != "Main menu" ]]; then
        current_menu="Main menu"
        cursor=0
    fi
}

# ===== MAIN LOOP =====
# while true; do
#     draw_menu
    
#     # Read key input (1 char for normal keys, 3 for arrows)
#     read -rsn1 key
    
#     # Check for escape sequence (arrows)
#     if [[ "$key" == $'\x1b' ]]; then
#         read -rsn2 -t 0.1 key_seq
#         case "$key_seq" in
#             '[A') ((cursor > 0)) && ((cursor--)) ;;  # Up
#             '[B') ((cursor < $((${#items[@]}-1)))) && ((cursor++)) ;;  # Down
#         esac
#     else
#         # Handle other keys
#         case "$key" in
#             " ") process_selection ;;  # Space
#             "") process_selection ;;   # Enter
#             $'\x7f') go_back ;;       # Backspace
#             [qQ]) go_back;;    # Quit
#             [rR]) fetch_packages ;;   # Refresh packages
#         esac
#     fi
# done

# ===== MAIN LOOP =====
main_loop() {
    while true; do
        draw_menu
        
        read -rsn1 key
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key_seq
            case "$key_seq" in
                '[A') ((cursor > 0)) && ((cursor--)) ;;
                '[B') ((cursor < $((${#items[@]}-1)))) && ((cursor++)) ;;
            esac
        else
            case "$key" in
                " "|"") process_selection ;;
                $'\x7f') go_back ;;
                [qQ]) go_back ;;
                [rR]) refresh_packages ;;
            esac
        fi
    done
}

# ===== MAIN FUNCTION =====
main() {
    welcome_screen
    main_loop
}

# Start
main