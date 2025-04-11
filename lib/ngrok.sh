#!/bin/bash

ngrok()
{
    echo -e "${BLUE}[+] Starting ngrok on port 8080...${RESET}"
    ngrok http 8080 &>/dev/null &
    sleep 5
    NGHOST=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r .tunnels[0].public_url | sed 's|https://||')
}