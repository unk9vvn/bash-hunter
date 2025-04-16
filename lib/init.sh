#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

ngrok()
{
    echo -e "${BLUE}[+] Starting ngrok on port 8080...${RESET}"

    # Start ngrok
    ngrok http 8080 &>/dev/null &
    sleep 5

    # Fetch the public URL
    local response=$(curl -s http://127.0.0.1:4040/api/tunnels)

    if [[ -z "$response" || "$response" == "null" ]]; then
        echo -e "${RED}[-] Error: Failed to get ngrok tunnel info. Is ngrok running?${RESET}"
        return 1
    fi

    NGHOST=$(echo "$response" | jq -r .tunnels[0].public_url | sed 's|https://||')

    if [[ -z "$NGHOST" || "$NGHOST" == "null" ]]; then
        echo -e "${RED}[-] Error: Could not extract ngrok public URL.${RESET}"
        return 1
    fi

    echo -e "${GREEN}[+] ngrok tunnel established at: $NGHOST${RESET}"
}
