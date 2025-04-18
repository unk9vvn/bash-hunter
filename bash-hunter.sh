#!/bin/bash

# Global configuration
VERSION='1.5'
CONFIG_DIR="${HOME}/.config/bash-hunter"
LOG_DIR="${HOME}/.logs/bash-hunter"
GITHUB_REPO="unk9vvn/bash-hunter"

# Color Variables
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Function to display error messages and exit
error_exit() {
    echo -e "${RED}[-] Error: $1${RESET}" >&2
    exit 1
}

# Function to display success messages
success_msg() {
    echo -e "${GREEN}[+] $1${RESET}"
}

# Function to display warning messages
warning_msg() {
    echo -e "${YELLOW}[!] $1${RESET}"
}

# Function to display info messages
info_msg() {
    echo -e "${BLUE}[*] $1${RESET}"
}

# Check for GitHub token and set it if needed
manage_github_token() {
    local input_token="$1"
    
    # If token is provided as argument, use it directly
    if [ -n "$input_token" ]; then
        TOKEN="$input_token"
        mkdir -p "${CONFIG_DIR}"
        echo "$TOKEN" > "${CONFIG_DIR}/token"
        chmod 600 "${CONFIG_DIR}/token"
        success_msg "GitHub token saved successfully"
        return 0
    fi
    
    # Otherwise check for existing token
    if [ -f "${CONFIG_DIR}/token" ]; then
        TOKEN=$(< "${CONFIG_DIR}/token")
    elif [ -n "$BASH_HUNTER_TOKEN" ]; then
        TOKEN="$BASH_HUNTER_TOKEN"
    else
        warning_msg "GitHub token not found"
        read -rp "Please enter your GitHub token: " TOKEN
        
        # Save the token
        mkdir -p "${CONFIG_DIR}"
        echo "$TOKEN" > "${CONFIG_DIR}/token"
        chmod 600 "${CONFIG_DIR}/token"
    fi
    
    if [ -z "$TOKEN" ]; then
        error_exit "GitHub token is required"
    fi
}

# Check required dependencies
check_dependencies() {
    # List of required programs
    local deps="wget curl git"
    local missing_deps=""
    
    # Check for ifconfig (install net-tools if missing)
    if ! command -v ifconfig &>/dev/null; then
        missing_deps="net-tools"
        warning_msg "ifconfig not found, net-tools package will be installed"
    fi
    
    # Check other essential programs
    for dep in $deps; do
        if ! command -v "$dep" &>/dev/null; then
            missing_deps+=" $dep"
            warning_msg "$dep not found, will be installed"
        fi
    done
    
    # If any programs need to be installed
    if [ -n "$missing_deps" ]; then
        info_msg "Installing required packages:$missing_deps"
        if apt-get update -qq && apt-get install -y $missing_deps; then
            success_msg "All packages installed successfully"
        else
            error_exit "Failed to install packages"
        fi
    else
        success_msg "All required dependencies are already installed"
    fi
}

# Kill any running processes
cleanup_processes() {
    info_msg "Cleaning up any running processes..."
    if pgrep -f 'ngrok' &>/dev/null; then
        pkill -f 'ngrok' && success_msg "Killed ngrok process" 
    fi
    
    if pgrep -f 'ruby' &>/dev/null; then
        pkill -f 'ruby' && success_msg "Killed ruby process" 
    fi
}

# Unk9vvN logo using printf
display_logo() {
    reset
    clear
    printf "${GREEN}                            --/osssssssssssso/--                    \n"
    printf "${GREEN}                        -+sss+-+--os.yo:++/.o-/sss+-                \n"
    printf "${GREEN}                     /sy+++-.h.-dd++m+om/s.h.hy/:+oys/              \n"
    printf "${GREEN}                  .sy/// h/h-:d-y:/+-/+-+/-s/sodooh:///ys.          \n"
    printf "${GREEN}                -ys-ss/:y:so-/osssso++++osssso+.oo+/s-:o.sy-        \n"
    printf "${GREEN}              -ys:oossyo/+oyo/:-:.-:.:/.:/-.-:/syo/+/s+:oo:sy-      \n"
    printf "${GREEN}             /d/:-soh/-+ho-.:::--:- .os: -:-.:-/::sy+:+ysso+:d/     \n"
    printf "${GREEN}            sy-..+oo-+h:--:..hy+y/  :s+.  /y/sh..:/-:h+-oyss:.ys    \n"
    printf "${WHITE}           ys :+oo/:d/   .m-yyyo/- - -:   .+oyhy-N.   /d::yosd.sy   \n"
    printf "${WHITE}          oy.++++//d.  ::oNdyo:     .--.     :oyhN+-:  .d//s//y.ys  \n"
    printf "${WHITE}         :m-y+++//d-   dyyy++::-. -.o.-+.- .-::/+hsyd   -d/so+++.m: \n"
    printf "${WHITE}        -d/-/+++.m-  /.ohso- ://:///++++///://:  :odo.+  -m.syoo:/d-\n"
    printf "${WHITE}        :m-+++y:y+   smyms-   -//+/-ohho-/+//-    omsmo   +y s+oy-m:\n"
    printf "${WHITE}        sy:+++y-N-  -.dy+:...-- :: ./hh/. :: --...//hh.:  -N-o+/:-so\n"
    printf "${WHITE}        yo-///s-m   odohd.-.--:/o.-+/::/+-.o/:--.--hd:ho   m-s+++-+y\n"
    printf "${WHITE}        yo::/+o-m   -yNy/:  ...:+s.//:://.s+:...  :/yNs    m-h++++oy\n"
    printf "${WHITE}        oy/hsss-N-  oo:oN-   .-o.:ss:--:ss:.o-.   -My-oo  -N-o+++.so\n"
    printf "${WHITE}        :m :++y:y+   sNMy+: -+/:.--:////:--.:/+- -+hNNs   +y-o++o-m:\n"
    printf "${WHITE}        -d/::+o+.m-  -:/+ho:.       -//-       ./sdo::-  -m-o++++/d-\n"
    printf "${WHITE}         :m-yo++//d- -ommMo//        -:        +oyNhmo- -d//s+++-m: \n"
    printf "${WHITE}          oy /o++//d.  -::/oMss-   -+++s     :yNy+/:   .d//y+---ys  \n"
    printf "${WHITE}           ys--+o++:d/ -/sdmNysNs+/./-//-//hNyyNmmy+- /d-+y--::sy   \n"
    printf "${RED}              sy:..ooo-+h/--.-//odm/hNh--yNh+Ndo//-./:/h+-so+:+/ys    \n"
    printf "${RED}               /d-o.ssy+-+yo:/:/:-:+sho..ohs/-:://::oh+.h//syo-d/     \n"
    printf "${RED}                -ys-oosyss:/oyy//::..-.--.--:/.//syo+-ys//o/.sy-      \n"
    printf "${RED}                  -ys.sooh+d-s:+osssysssosssssso:/+/h:/yy/.sy-        \n"
    printf "${RED}                    .sy/:os.h--d/o+-/+:o:/+.+o:d-y+h-o+-+ys.          \n"
    printf "${RED}                       :sy+:+ s//sy-y.-h-m/om:s-y.++/+ys/             \n"
    printf "${RED}                          -+sss+/o/ s--y.s+/:++-+sss+-                \n"
    printf "${RED}                              --/osssssssssssso/--                    \n"
    printf "${BLUE}                                   Unk9vvN                           \n"
    printf "${YELLOW}                           https://unk9vvn.com                     \n"
    printf "${CYAN}                              Bash Hunter ${VERSION}                 \n"
    printf "\n\n"
}

# Show help menu using echo
display_help() {
    echo "${GREEN} 🟢 ${WHITE}-d <domain>         ${CYAN}→${WHITE} 🔍 Scan a single domain"
    echo "${GREEN} 📂 ${WHITE}-D <file>           ${CYAN}→${WHITE} 📜 Scan multiple domains from file"
    echo "${GREEN} 🧪 ${WHITE}-P <project_path>   ${CYAN}→${WHITE} 🔬 Run Semgrep on a local project folder"
    echo "${GREEN} 🔄 ${WHITE}-u                  ${CYAN}→${WHITE} 🔄 Update bash-hunter to the latest version"
    echo "${GREEN} 🔑 ${WHITE}-t <token>          ${CYAN}→${WHITE} 🔒 Set GitHub token"
    echo "${GREEN} 🆘 ${WHITE}-h                  ${CYAN}→${WHITE} 📖 Show this help menu"
    echo "${MAGENTA} 📌 Example usage:"
    echo "${WHITE}    💻 sudo bash-hunter -d example.com"
    echo "${WHITE}    💻 sudo bash-hunter -D domains.txt"
    echo "${WHITE}    💻 sudo bash-hunter -P /web-project"
    echo "${WHITE}    💻 sudo bash-hunter -u"
}

# Install or update bash-hunter
install_update() {
    local install_path="/usr/share/bash-hunter"
    local bin_path="/usr/bin/bash-hunter"
    
    # Check if we need to install or update
    local action="Installed"
    if [ -d "$install_path" ]; then
        action="Updated"
        local remote_version
        remote_version=$(curl -s -H "Authorization: token $TOKEN" "https://raw.githubusercontent.com/$GITHUB_REPO/main/version" || echo "0")
        
        if [ "$remote_version" = "$VERSION" ]; then
            info_msg "You already have the latest version ($VERSION)"
            return 0
        fi
        
        info_msg "Updating from version $VERSION to $remote_version..."
        rm -rf "$install_path"
    fi
    
    # Clone repository
    if ! git clone "https://$TOKEN@github.com/$GITHUB_REPO" "$install_path"; then
        error_exit "Failed to clone repository"
    fi
    
    # Set permissions
    chmod -R 755 "$install_path"
    
    # Create executable in path
    cat > "$bin_path" << EOF
#!/bin/bash
cd "$install_path" && exec bash bash-hunter.sh "\$@"
EOF
    chmod +x "$bin_path"
    
    success_msg "Successfully $action: bash-hunter"
    success_msg "Run with: sudo bash-hunter"
    exit 0
}

# Create directories for logs and temporary files
setup_directories() {
    local domain="$1"
    mkdir -p "$LOG_DIR"
    chmod 750 "$LOG_DIR"
    
    # Ensure temporary directories are properly cleaned
    local tmp_dir="/tmp/$domain"
    if [ -d "$tmp_dir" ]; then
        rm -rf "$tmp_dir"
    fi
    mkdir -p "$tmp_dir"
}

# Create templates
create_temp_files() {
    local domain="$1"
    local tmp_dir="/tmp/$domain"
    
    echo "8.8.8.8" > "$tmp_dir/resolvers.txt"
    info_msg "Created temporary files in $tmp_dir"
}

# Validate domain name format
validate_domain() {
    local domain="$1"
    if ! echo "$domain" | grep -qP '(?=^.{1,254}$)(^(?>(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.)+[a-zA-Z]{2,}$)'; then
        error_exit "Invalid domain format: $domain"
    fi
}

# Load all libraries
load_libraries() {
    local lib_dir="./lib"
    local libs=("subdomains" "ports" "directories" "endpoints" "parameters" "scans")
    
    for lib in "${libs[@]}"; do
        local lib_path="${lib_dir}/${lib}.sh"
        if [ -f "$lib_path" ]; then
            # shellcheck source=/dev/null
            source "$lib_path"
        else
            error_exit "Required library not found: $lib_path"
        fi
    done
}

# Run tools on a domain
run_recon() {
    local domain="$1"
    local tmp_dir="/tmp/$domain"
    
    info_msg "Starting reconnaissance on $domain"
    
    # Load libraries
    load_libraries
    
    # Start ngrok if function exists
    if type -t ngrok &>/dev/null; then
        ngrok
    fi
    
    # Run tools sequentially with progress tracking
    local total_steps=5
    local current_step=1
    
    info_msg "[$current_step/$total_steps] Discovering subdomains..."
    subdomains "$domain" "$tmp_dir"
    ((current_step++))
    
    info_msg "[$current_step/$total_steps] Scanning ports..."
    ports "$tmp_dir"
    ((current_step++))
    
    info_msg "[$current_step/$total_steps] Enumerating directories..."
    directories "$domain" "$tmp_dir"
    ((current_step++))
    
    info_msg "[$current_step/$total_steps] Finding endpoints..."
    endpoints "$domain" "$tmp_dir"
    ((current_step++))
    
    info_msg "[$current_step/$total_steps] Discovering parameters..."
    parameters "$domain" "$tmp_dir"
    
    info_msg "Running vulnerability scans..."
    nuclei "$domain"
}

# Run security scan on local project
run_project_scan() {
    local project_path="$1"
    
    if [ ! -d "$project_path" ]; then
        error_exit "Project directory not found: $project_path"
    fi
    
    info_msg "Running Semgrep scan on $project_path"
    semgrep "$project_path"
}

# Process each domain
process_domain() {
    local domain="$1"
    
    # Validate domain
    validate_domain "$domain"
    
    # Set up directories
    setup_directories "$domain"
    
    # Create temp files
    create_temp_files "$domain"
    
    # Run reconnaissance
    run_recon "$domain"
    
    success_msg "Scan completed for $domain"
}

# Process domains from file
process_domain_file() {
    local domain_file="$1"
    
    if [ ! -f "$domain_file" ]; then
        error_exit "File not found: $domain_file"
    fi
    
    success_msg "Processing domains from file: $domain_file"
    
    # Read file line by line
    while IFS= read -r domain || [ -n "$domain" ]; do
        # Skip empty lines and comments
        if [[ -z "$domain" || "$domain" =~ ^# ]]; then
            continue
        fi
        process_domain "$domain"
    done < "$domain_file"
}

# Main function
main() {
    # Check if root
    if [ "$(id -u)" -ne 0 ]; then
        error_exit "This script must be run as root (use sudo)"
    fi
    
    # No arguments provided, show help
    if [ $# -eq 0 ]; then
        display_logo
        display_help
        exit 0
    fi
    
    # Parse command line arguments
    while getopts ":d:D:P:t:uh" opt; do
        case "${opt}" in
            d)  
                display_logo
                process_domain "${OPTARG}"
                ;;
            D)  
                display_logo
                process_domain_file "${OPTARG}"
                ;;
            P)  
                display_logo
                run_project_scan "${OPTARG}"
                ;;
            t)  
                display_logo
                manage_github_token "${OPTARG}"
                ;;
            u)  
                display_logo
                install_update
                ;;
            h)  
                display_logo
                display_help
                exit 0
                ;;
            *)  
                display_logo
                display_help
                exit 1
                ;;
        esac
    done
}

# Initial setup
check_dependencies
cleanup_processes
manage_github_token

# Call main with all args
main "$@"
