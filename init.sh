#!/bin/bash

init()
{
    # Get LAN and WAN IP addresses
    LAN=$(hostname -I | awk '{print $1}')
    WAN=$(curl -s https://api.ipify.org)

    # Kill any running ngrok or ruby instances
    pkill -f 'ngrok|ruby'

    # Install apt tools
    apt update;apt install -qy golang-go curl wget hakrawler wpscan sqlmap ffuf metasploit-framework beef-xss wpscan joomscan 

    # pip install
    pip3 install --break-system-packages arjun 

	# install ngrok
	if [ ! -f "/usr/local/bin/ngrok" ]; then
		name="ngrok"
		wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O /tmp/$name.tgz
		tar -xvzf /tmp/$name.tgz -C /usr/local/bin;rm -f /tmp/$name.tgz
		chmod +x /usr/local/bin/ngrok
	fi

	# install x8
	if [ ! -d "/usr/share/x8" ]; then
		name="x8"
		mkdir -p /usr/share/x8
		wget https://github.com/Sh1Yo/x8/releases/latest/download/x86_64-linux-x8.gz -O /tmp/$name.gz
		gunzip -c /tmp/$name.gz > /usr/share/$name/$name;rm -f /tmp/$name.gz
		chmod 755 /usr/share/$name/*
		ln -fs /usr/share/$name/x8 /usr/bin/$name
		chmod +x /usr/bin/$name
	fi

    # List of tools to check and install if necessary
    tools=("naabu" "httpx" "favirecon" "waybackurls" "katana" "qsreplace" "cvemap" "mapcidr" "gf" "anew" "gau")

    # Loop through each tool and check if it exists
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "$tool not found. Installing..."
            
            # Install the tool
            case $tool in
                "naabu")
                    go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
                    ln -fs ~/go/bin/naabu /usr/bin/naabu
                    ;;
                "httpx")
                    go install github.com/projectdiscovery/httpx/cmd/httpx@latest
                    ln -fs ~/go/bin/httpx /usr/bin/httpx
                    ;;
                "favirecon")
                    go install github.com/edoardottt/favirecon/cmd/favirecon@latest
                    ln -fs ~/go/bin/favirecon /usr/bin/favirecon
                    ;;
                "waybackurls")
                    go install github.com/tomnomnom/waybackurls@latest
                    ln -fs ~/go/bin/waybackurls /usr/bin/waybackurls
                    ;;
                "katana")
                    go install github.com/projectdiscovery/katana/cmd/katana@latest
                    ln -fs ~/go/bin/katana /usr/bin/katana
                    ;;
                "qsreplace")
                    go install github.com/tomnomnom/qsreplace@latest
                    ln -fs ~/go/bin/qsreplace /usr/bin/qsreplace
                    ;;
                "cvemap")
                    go install github.com/projectdiscovery/cvemap/cmd/cvemap@latest
                    ln -fs ~/go/bin/cvemap /usr/bin/cvemap
                    ;;
                "mapcidr")
                    go install github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest
                    ln -fs ~/go/bin/mapcidr /usr/bin/mapcidr
                    ;;
                "gf")
                    go install github.com/tomnomnom/gf@latest
                    ln -fs ~/go/bin/gf /usr/bin/gf
                    ;;
                "anew")
                    go install github.com/tomnomnom/anew@latest
                    ln -fs ~/go/bin/anew /usr/bin/anew
                    ;;
                "gau")
                    go install github.com/lc/gau/v2/cmd/gau@latest
                    ln -fs ~/go/bin/gau /usr/bin/gau
                    ;;
            esac
        else
            echo "$tool is already installed."
        fi
    done
}