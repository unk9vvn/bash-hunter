#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Init function that does everything
init() {
    # Check root access
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}[-] This script must be run as root${RESET}"
        exit 1
    fi

    # Start ngrok
    echo -e "${BLUE}[+] Setting up ngrok on port 8080...${RESET}"
    ngrok http 8080 &>/dev/null &
    sleep 3

    # Get the public URL
    local response=$(curl -s http://127.0.0.1:4040/api/tunnels)
    
    if [[ -n "$response" && "$response" != "null" ]]; then
        NGHOST=$(echo "$response" | jq -r .tunnels[0].public_url | sed 's|https://||')
        
        if [[ -n "$NGHOST" && "$NGHOST" != "null" ]]; then
            echo -e "${GREEN}[+] ngrok tunnel established at: $NGHOST${RESET}"
        else
            echo -e "${RED}[-] Error: Could not extract ngrok public URL.${RESET}"
        fi
    else
        echo -e "${RED}[-] Error: Failed to get ngrok tunnel info. Is ngrok running?${RESET}"
    fi

    # Install packages
    echo -e "${BLUE}[+] Updating package lists...${RESET}"
    apt update -qq
    
    echo -e "${BLUE}[+] Installing apt packages...${RESET}"
    apt install -qy hakrawler paramspider wpscan sqlmap ffuf metasploit-framework beef-xss wpscan joomscan nuclei seclists jq curl unzip golang
    
    echo -e "${BLUE}[+] Installing Python packages...${RESET}"
    pip3 install --break-system-packages arjun semgrep
    
    # Install ngrok
    if [ ! -f "/usr/local/bin/ngrok" ]; then
        echo -e "${BLUE}[+] Installing ngrok...${RESET}"
        wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O /tmp/ngrok.tgz
        tar -xvzf /tmp/ngrok.tgz -C /usr/local/bin
        rm -f /tmp/ngrok.tgz
        chmod +x /usr/local/bin/ngrok
        echo -e "${GREEN}[+] Successfully installed ngrok${RESET}"
    fi

    # Install x8
    if [ ! -d "/usr/share/x8" ]; then
        echo -e "${BLUE}[+] Installing x8...${RESET}"
        mkdir -p /usr/share/x8
        wget https://github.com/Sh1Yo/x8/releases/latest/download/x86_64-linux-x8.gz -O /tmp/x8.gz
        gunzip -c /tmp/x8.gz > /usr/share/x8/x8
        rm -f /tmp/x8.gz
        chmod 755 /usr/share/x8/*
        ln -fs /usr/share/x8/x8 /usr/bin/x8
        chmod +x /usr/bin/x8
        echo -e "${GREEN}[+] Successfully installed x8${RESET}"
    fi

    # Install rustscan
    if [ ! -f "/usr/bin/rustscan" ]; then
        echo -e "${BLUE}[+] Installing rustscan...${RESET}"
        wget https://github.com/bee-san/RustScan/releases/download/2.4.1/rustscan.deb.zip -O /tmp/rustscan.zip
        unzip /tmp/rustscan.zip -d /tmp
        rm -f /tmp/rustscan.zip
        chmod +x /tmp/rustscan_2.4.1-1_amd64.deb
        dpkg -i /tmp/rustscan_2.4.1-1_amd64.deb
        rm -f /tmp/rustscan_2.4.1-1_amd64.deb
        rm -f /tmp/rustscan.tmp0-stripped
        echo -e "${GREEN}[+] Successfully installed rustscan${RESET}"
    fi

    # Install Go tools
    echo -e "${BLUE}[+] Installing Go tools...${RESET}"
    
    # Define tools with their repository paths
    declare -A go_tools=(
        ["naabu"]="github.com/projectdiscovery/naabu/v2/cmd/naabu"
        ["httpx"]="github.com/projectdiscovery/httpx/cmd/httpx"
        ["favirecon"]="github.com/edoardottt/favirecon/cmd/favirecon"
        ["waybackurls"]="github.com/tomnomnom/waybackurls"
        ["katana"]="github.com/projectdiscovery/katana/cmd/katana"
        ["qsreplace"]="github.com/tomnomnom/qsreplace"
        ["cvemap"]="github.com/projectdiscovery/cvemap/cmd/cvemap"
        ["mapcidr"]="github.com/projectdiscovery/mapcidr/cmd/mapcidr"
        ["gf"]="github.com/tomnomnom/gf"
        ["anew"]="github.com/tomnomnom/anew"
        ["gau"]="github.com/lc/gau/v2/cmd/gau"
    )
    
    # Install each Go tool
    for tool in "${!go_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo -e "${BLUE}[+] Installing $tool...${RESET}"
            go install "${go_tools[$tool]}"@latest
            ln -fs ~/go/bin/"$tool" /usr/bin/"$tool"
            echo -e "${GREEN}[+] Successfully installed $tool${RESET}"
        else
            echo -e "${GREEN}[+] $tool is already installed${RESET}"
        fi
    done
    
    echo -e "${GREEN}[+] All tools have been installed successfully!${RESET}"
}
