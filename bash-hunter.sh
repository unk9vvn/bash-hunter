#!/bin/bash
source ./init.sh
source ./subdomains.sh
source ./ports.sh
source ./directories.sh
source ./endpoints.sh
source ./parameters.sh
ver="1.0"

# Define color codes as variables
GREEN="\033[32m"
BLUE="\033[34m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"

# Create templates
temp()
{
    local DOMAIN="$1"
    TMP="/tmp/$DOMAIN"
    mkdir -p "$TMP"
    echo "8.8.8.8" > $TMP/resolvers.txt
}

# Ngrok Start
ngrok()
{
    echo -e "${BLUE}[+] Starting ngrok on port 8080...${RESET}"
    ngrok http 8080 &>/dev/null &
    sleep 5
    NGHOST=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r .tunnels[0].public_url | sed 's|https://||')
}

# Main process
process()
{
    # init
    local DOMAIN="$1"
    temp "$DOMAIN"
    ngrok

    # General Scans
    subdomains "$DOMAIN" "$TMP"
    ports "$TMP"
    directories "$DOMAIN" "$TMP"
    endpoints "$DOMAIN" "$TMP"
    parameters "$DOMAIN" "$TMP"
    
    # Clean up ngrok and beef process
    pkill -f 'ngrok|ruby'
}

# main executions
main()
{
    # Check root running
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}[-] This script must be run as root (use sudo).${RESET}"
        exit 1
    fi
    
    # Ensure at least one argument is passed
    if [[ "$#" -lt 1 ]]; then
        echo -e "${YELLOW}[-] Usage: $0 <WEBSITE|FILE>${RESET}"
        exit 1
    fi

    init

    # Process either a URL or a file containing domains
    if [[ -f "$1" ]]; then
        echo -e "${GREEN}[+] Processing domains from file: $1${RESET}"
        while IFS= read -r DOMAIN; do
            [[ -z "$DOMAIN" || "$DOMAIN" =~ ^# ]] && continue
            process "$DOMAIN"
        done < "$1"
    else
        process "$1"
    fi
}

# Execute the script
main "$@"
