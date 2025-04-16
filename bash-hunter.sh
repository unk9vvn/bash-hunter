#!/bin/bash
source ./lib/init.sh
source ./lib/subdomains.sh
source ./lib/ports.sh
source ./lib/directories.sh
source ./lib/endpoints.sh
source ./lib/parameters.sh
source ./lib/nuclei.sh
VER="1.2"
TOKEN="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"

# Define color codes as variables
GREEN='\033[32m'
BLUE='\033[34m'
RED='\033[31m'
YELLOW='\033[33m'
RESET='\033[0m'

# Get LAN and WAN IP addresses
LAN=$(hostname -I | awk '{print $1}')
WAN=$(curl -s https://api.ipify.org)

# Kill any running ngrok or ruby instances
pkill -f 'ngrok|ruby'

# Unk9vvN logo
logo()
{
    reset;clear
    printf "$GREEN"   "                            --/osssssssssssso/--                    "
    printf "$GREEN"   "                        -+sss+-+--os.yo:++/.o-/sss+-                "
    printf "$GREEN"   "                     /sy+++-.h.-dd++m+om/s.h.hy/:+oys/              "
    printf "$GREEN"   "                  .sy/// h/h-:d-y:/+-/+-+/-s/sodooh:///ys.          "
    printf "$GREEN"   "                -ys-ss/:y:so-/osssso++++osssso+.oo+/s-:o.sy-        "
    printf "$GREEN"   "              -ys:oossyo/+oyo/:-:.-:.:/.:/-.-:/syo/+/s+:oo:sy-      "
    printf "$GREEN"   "             /d/:-soh/-+ho-.:::--:- .os: -:-.:-/::sy+:+ysso+:d/     "
    printf "$GREEN"   "            sy-..+oo-+h:--:..hy+y/  :s+.  /y/sh..:/-:h+-oyss:.ys    "
    printf "$WHITE"   "           ys :+oo/:d/   .m-yyyo/- - -:   .+oyhy-N.   /d::yosd.sy   "
    printf "$WHITE"   "          oy.++++//d.  ::oNdyo:     .--.     :oyhN+-:  .d//s//y.ys  "
    printf "$WHITE"   "         :m-y+++//d-   dyyy++::-. -.o.-+.- .-::/+hsyd   -d/so+++.m: "
    printf "$WHITE"   "        -d/-/+++.m-  /.ohso- ://:///++++///://:  :odo.+  -m.syoo:/d-"
    printf "$WHITE"   "        :m-+++y:y+   smyms-   -//+/-ohho-/+//-    omsmo   +y s+oy-m:"
    printf "$WHITE"   "        sy:+++y-N-  -.dy+:...-- :: ./hh/. :: --...//hh.:  -N-o+/:-so"
    printf "$WHITE"   "        yo-///s-m   odohd.-.--:/o.-+/::/+-.o/:--.--hd:ho   m-s+++-+y"
    printf "$WHITE"   "        yo::/+o-m   -yNy/:  ...:+s.//:://.s+:...  :/yNs    m-h++++oy"
    printf "$WHITE"   "        oy/hsss-N-  oo:oN-   .-o.:ss:--:ss:.o-.   -My-oo  -N-o+++.so"
    printf "$WHITE"   "        :m :++y:y+   sNMy+: -+/:.--:////:--.:/+- -+hNNs   +y-o++o-m:"
    printf "$WHITE"   "        -d/::+o+.m-  -:/+ho:.       -//-       ./sdo::-  -m-o++++/d-"
    printf "$WHITE"   "         :m-yo++//d- -ommMo//        -:        +oyNhmo- -d//s+++-m: "
    printf "$WHITE"   "          oy /o++//d.  -::/oMss-   -+++s     :yNy+/:   .d//y+---ys  "
    printf "$WHITE"   "           ys--+o++:d/ -/sdmNysNs+/./-//-//hNyyNmmy+- /d-+y--::sy   "
    printf "$RED"     "            sy:..ooo-+h/--.-//odm/hNh--yNh+Ndo//-./:/h+-so+:+/ys    "
    printf "$RED"     "             /d-o.ssy+-+yo:/:/:-:+sho..ohs/-:://::oh+.h//syo-d/     "
    printf "$RED"     "              -ys-oosyss:/oyy//::..-.--.--:/.//syo+-ys//o/.sy-      "
    printf "$RED"     "                -ys.sooh+d-s:+osssysssosssssso:/+/h:/yy/.sy-        "
    printf "$RED"     "                  .sy/:os.h--d/o+-/+:o:/+.+o:d-y+h-o+-+ys.          "
    printf "$RED"     "                     :sy+:+ s//sy-y.-h-m/om:s-y.++/+ys/             "
    printf "$RED"     "                        -+sss+/o/ s--y.s+/:++-+sss+-                "
    printf "$RED"     "                            --/osssssssssssso/--                    "
    printf "$BLUE"    "                                  Unk9vvN                           "
    printf "$YELLOW"  "                            https://unk9vvn.com                     "
    printf "$CYAN"    "                              Bash Hunter "$ver"                    "
    printf "\n\n"
}

# Install tools
install()
{
    # Install apt tools
    apt update
    apt install -qy curl wget jq p7zip p7zip-full zipalign \
        golang-go \
        hakrawler wpscan sqlmap ffuf metasploit-framework beef-xss wpscan joomscan nuclei seclists 

    # pip install
    pip3 install --break-system-packages arjun semgrep 

    # install ngrok
    if [ ! -f "/usr/local/bin/ngrok" ]; then
        name="ngrok"
        wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O /tmp/$name.tgz
        tar -xvzf /tmp/$name.tgz -C /usr/local/bin;rm -f /tmp/$name.tgz
        chmod +x /usr/local/bin/ngrok
        printf "$GREEN"  "[*] Successfully Installed $name"
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
        printf "$GREEN"  "[*] Successfully Installed $name"
    fi

	# install rustscan
	if [ ! -f "/usr/bin/rustscan" ]; then
		name="rustscan"
		wget https://github.com/bee-san/RustScan/releases/download/2.4.1/rustscan.deb.zip -O /tmp/$name.zip
        unzip /tmp/$name.zip -d /tmp;rm -f /tmp/$name.zip
		chmod +x /tmp/rustscan_2.4.1-1_amd64.deb;dpkg -i /tmp/rustscan_2.4.1-1_amd64.deb
        rm -f /tmp/rustscan_2.4.1-1_amd64.deb;rm -f /tmp/rustscan.tmp0-stripped
		printf "$GREEN"  "[*] Successfully Installed $name"
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

    # install & update bash-hunter
    if [ ! -d "/usr/share/bash-hunter" ]; then
        NAME="bash-hunter"
        git clone https://a9v8i:$TOKEN@github.com/unk9vvn/bash-hunter /usr/share/$name
        chmod 755 /usr/share/$NAME/*
        cat > /usr/bin/$NAME << EOF
#!/bin/bash
cd /usr/share/$NAME;bash $NAME.sh "\$@"
EOF
        chmod +x /usr/bin/$NAME
        printf "$GREEN"  "[*] Successfully Installed $NAME"
    elif [ "$(curl -s https://a9v8i:$TOKEN@raw.githubusercontent.com/unk9vvn/bash-hunter/main/version)" != $VER ]; then
        NAME="bash-hunter"
        git clone https://a9v8i:$TOKEN@github.com/unk9vvn/bash-hunter /usr/share/$name
        chmod 755 /usr/share/$NAME/*
        cat > /usr/bin/$NAME << EOF
#!/bin/bash
cd /usr/share/$NAME;bash $NAME.sh "\$@"
EOF
        chmod +x /usr/bin/$NAME
        printf "$GREEN"  "[*] Successfully Updated $NAME"
        bash /usr/share/$NAME/$NAME.sh
    fi
}

# Create templates
temp()
{
    local DOMAIN="$1"
    TMP="/tmp/$DOMAIN"
    mkdir -p "$TMP"
    echo "8.8.8.8" > $TMP/resolvers.txt
}

# Main process
process()
{
    # init
    local DOMAIN="$1"
    temp "$DOMAIN"
    ngrok

    # Recon
    subdomains "$DOMAIN" "$TMP"
    ports "$TMP"
    directories "$DOMAIN" "$TMP"
    endpoints "$DOMAIN" "$TMP"
    parameters "$DOMAIN" "$TMP"

    # Scan
    nuclei "$DOMAIN"
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

    install
    logo

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
