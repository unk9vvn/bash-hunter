#!/bin/bash
ver="1.0"

# Define color codes as variables
GREEN="\033[32m"
BLUE="\033[34m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"

# Function to check and install necessary tools
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

# Subdomain FUZZ
subdomains()
{
    subfinder -d $DOMAIN -all -recursive -silent -o $TMP/sub_one.txt
    curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' >> $TMP/sub_one.txt
    httpx -l $TMP/sub_one.txt -resolve -silent -o $TMP/sub_two.txt
    cat $TMP/sub_two.txt | sort -u | anew $TMP/sub_three.txt > $TMP/subdomains.txt
    rm -f $TMP/sub_one.txt $TMP/sub_two.txt $TMP/sub_three.txt
    echo -e "${RED}[-] Success FUZZ and SAVE ${TMP}/subdomains.txt ${RESET}"
}

# Port FUZZ
port()
{
    naabu -list $TMP/subdomains.txt -silent -o $TMP/port_one.txt
    httpx -l $TMP/port_one.txt -resolve -silent -o $TMP/port_two.txt
    cat $TMP/port_two.txt | sort -u | anew $TMP/port_three.txt > $TMP/ports.txt
    rm -f $TMP/port_one.txt $TMP/port_two.txt $TMP/port_three.txt
    echo -e "${RED}[-] Success FUZZ and SAVE ${TMP}/ports.txt ${RESET}"
}

# Directory FUZZ
directories()
{
    USER_AGENTS=(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0"
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:85.0) Gecko/20100101 Firefox/85.0"
        "Mozilla/5.0 (iPhone; CPU iPhone OS 14_4_2 like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/537.36"
        "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/537.36"
        "Mozilla/5.0 (Android 11; Mobile; rv:88.0) Gecko/88.0 Firefox/88.0"
        "Mozilla/5.0 (Linux; Android 10; Pixel 4 XL) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Mobile Safari/537.36"
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        "Mozilla/5.0 (Windows NT 6.1; rv:71.0) Gecko/20100101 Firefox/71.0"
    )

    # Randomly select a User-Agent from the array
    USER_AGENT=$(echo "${USER_AGENTS[@]}" | tr ' ' '\n' | shuf -n 1)

    # Define the headers
    HEADERS=(
        "User-Agent: $USER_AGENT"
        "Accept: */*"
        "Accept-Language: en-US,fa-IR;q=0.5"
        "Accept-Encoding: gzip, deflate, br, zstd"
        "Connection: keep-alive"
        "Upgrade-Insecure-Requests: 1"
        "Sec-Fetch-Dest: script"
        "Sec-Fetch-Mode: no-cors"
        "Sec-Fetch-Site: cross-site"
        "DNT: 1"
        "Sec-GPC: 1"
        "Priority: u=0, i"
        "Te: trailers"
    )

    # Extract cookies from response headers
    curl -s -I "$DOMAIN" | awk 'BEGIN {IGNORECASE=1} /^set-cookie:/ {print substr($0, 13)}' > $TMP/cookies.txt

    # Process cookies
    COOKIES=$(awk -F';' '{print $1}' "$TMP/cookies.txt" | tr '\n' '; ' | sed 's/; $//')

    # Append cookies if available
    if [[ -n "$COOKIES" ]]; then
        HEADERS+=("Cookie: $COOKIES")
    fi

    # Convert headers into ffuf parameters
    HEADER_PARAMS=()
    for HEADER in "${HEADERS[@]}"; do
        HEADER_PARAMS+=("-H" "$HEADER")
    done

    # Run ffuf
    ffuf -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt \
         -u "$DOMAIN/FUZZ" \
         -ac -c -s \
         -o $TMP/directories.txt \
         "${HEADER_PARAMS[@]}"
    echo -e "${RED}[-] Success FUZZ and SAVE ${TMP}/directories.txt ${RESET}"
}

# Endpoint FUZZ
endpoints()
{
    # 1. katana crawl
    katana -u $DOMAIN \
       -fr "(static|assets|img|images|css|fonts|icons|js|cdn|vendor|bootstrap)/" \
       -o /tmp/endpoint_one.txt \
       -xhr-extraction \
       -automatic-form-fill \
       -form \
       -silent \
       -strategy depth-first \
       -js-crawl \
       -extension-filter jpg,jpeg,png,gif,bmp,tiff,tif,webp,svg,ico,css,woff,woff2,eot,ttf,otf,mp4,mp3,avi \
       -headless --no-sandbox \
       -known-files all \
       -field url \
       -sf url

    # Extract only paths (remove scheme and domain), clean up, and save
    cat /tmp/urls.txt | \
    sed 's/\?.*//g' | \
    sed 's/\.aspx$//' | \
    sed 's/\/[^/]*\.json$//' | \
    grep -v '\.js$' | \
    grep -v '&amp' | \
    sed -E "s|https?://$(echo "$domain" | sed -E 's|https?://||')||" | \
    sort -u > /tmp/endpoint_one.txt

    # 2. gau (wayback, commoncrawl, etc)
    gau $DOMAIN --o $TMP/endpoint_two.txt 2>/dev/null

    # 3. waybackurls
    waybackurls $DOMAIN > $TMP/endpoint_three.txt 2>/dev/null

    # 4. hakrawler
    echo $DOMAIN | hakrawler -subs -depth 2 -plain -insecure > $TMP/endpoint_four.txt 2>/dev/null

    # Combine and clean
    cat $TMP/endpoint_one.txt $TMP/endpoint_two.txt $TMP/endpoint_three.txt $TMP/endpoint_four.txt | \
    sed 's/\?.*//g' | \
    sed 's/\.aspx$//' | \
    sed 's/\/[^/]*\.json$//' | \
    grep -v '\.js$' | \
    grep -v '\.css$' | \
    grep -v '\.jpg$' | \
    grep -v '\.png$' | \
    grep -v '&amp' | \
    sort -u | anew endpoints.txt > /dev/null
    echo -e "${RED}[-] Success FUZZ and SAVE ${TMP}/endpoints.txt ${RESET}"
}

# Parameter
parameters()
{
    x8 --url $DOMAIN \
    -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt \
    -o $TMP/hidden-params.txt 2>/dev/null
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
