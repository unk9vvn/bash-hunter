#!/bin/bash
VER='1.3'
TOKEN='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'

# Color Variables
RED='\e[1;31m%s\e[0m\n'
GREEN='\e[1;32m%s\e[0m\n'
YELLOW='\e[1;33m%s\e[0m\n'
BLUE='\e[1;34m%s\e[0m\n'
MAGENTO='\e[1;35m%s\e[0m\n'
CYAN='\e[1;36m%s\e[0m\n'
WHITE='\e[1;37m%s\e[0m\n'
RESET='\033[0m'

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[-] This script must be run as root (use sudo).${RESET}"
    exit 1
else
	# update & upgrade & clean up packages
	apt update;apt upgrade -qy;apt dist-upgrade -qy;apt autoremove -qy;apt autoclean

	# install required packages
	apt install -qy wget curl git net-tools gnupg apt-transport-https 

	# get current user and LAN IP address
	USERS=$(cd /home;ls | awk '{print $1}')
	LAN=$(hostname -I | awk '{print $1}')

	# Kill any running ngrok or ruby instances
	pkill -f 'ngrok|ruby'
fi

# Install & Update bash-hunter
if [ ! -d "/usr/share/bash-hunter" ]; then
    NAME="bash-hunter"
    git clone https://a9v8i:$TOKEN@github.com/unk9vvn/bash-hunter /usr/share/$NAME
    chmod 755 /usr/share/$NAME/*;chmod 755 /usr/share/$NAME/lib
    cat > /usr/bin/$NAME << EOF
#!/bin/bash
cd /usr/share/$NAME;bash $NAME.sh "\$@"
EOF
    chmod +x /usr/bin/$NAME
    echo -e "${GREEN}[+] Successfully Installed: $NAME${RESET}"
    echo -e "${GREEN}[+] sudo $NAME${RESET}"
    exit
elif [ "$(curl -s https://a9v8i:$TOKEN@raw.githubusercontent.com/unk9vvn/bash-hunter/main/version)" != $VER ]; then
    NAME="bash-hunter"
    git clone https://a9v8i:$TOKEN@github.com/unk9vvn/bash-hunter /usr/share/$NAME
    chmod 755 /usr/share/$NAME/*;chmod 755 /usr/share/$NAME/lib
    cat > /usr/bin/$NAME << EOF
#!/bin/bash
cd /usr/share/$NAME;bash $NAME.sh "\$@"
EOF
    chmod +x /usr/bin/$NAME
    echo -e "${GREEN}[+] Successfully Updated: $NAME${RESET}"
    echo -e "${GREEN}[+] sudo $NAME${RESET}"
    exit
fi

# Load libraries
source ./lib/init.sh
source ./lib/subdomains.sh
source ./lib/ports.sh
source ./lib/directories.sh
source ./lib/endpoints.sh
source ./lib/parameters.sh
source ./lib/scans.sh

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

# show help menu
help()
{
    logo
    echo -e "$GREEN 🟢 $WHITE-d <domain>         $CYAN→$WHITE 🔍 Scan a single domain"
    echo -e "$GREEN 📂 $WHITE-D <file>           $CYAN→$WHITE 📜 Scan multiple domains from file"
    echo -e "$GREEN 🧪 $WHITE-P <project_path>   $CYAN→$WHITE 🔬 Run Semgrep on a local project folder"
    echo -e "$GREEN 🆘 $WHITE-h                  $CYAN→$WHITE 📖 Show this help menu"
    echo -e "$MAGENTA 📌 Example usage:"
    echo -e "$WHITE    💻 sudo bash-hunter -d example.com"
    echo -e "$WHITE    💻 sudo bash-hunter -D domains.txt"
    echo -e "$WHITE    💻 sudo bash-hunter -P /web-project"
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
    semgrep "$TMP" "$PROJECT"
}

# main executions
main()
{
    # Parse command line arguments
    while getopts ":d:D:P:h" opt; do
        case "${opt}" in
            d) DOMAIN="${OPTARG}"
                echo -e "${GREEN}[+] Scanning single domain: $DOMAIN${RESET}"
                process "$DOMAIN"
            ;;
            D) DOMAIN_FILE="${OPTARG}"
                if [[ -f "$DOMAIN_FILE" ]]; then
                    echo -e "${GREEN}[+] Processing domains from file: $DOMAIN_FILE${RESET}"
                    while IFS= read -r DOMAIN; do
                        [[ -z "$DOMAIN" || "$DOMAIN" =~ ^# ]] && continue
                        process "$DOMAIN"
                    done < "$DOMAIN_FILE"
                else
                    echo -e "${RED}[-] File not found: $DOMAIN_FILE${RESET}"
                fi
            ;;
            P) PROJECT="${OPTARG}"
                echo -e "${GREEN}[+] Running semgrep scan on: $PROJECT${RESET}"
                process "$PROJECT"
            ;;
            h) help; exit 0 ;;
            *) help; exit 1 ;;
        esac
    done
}

# Call main with all args
main "$@"
