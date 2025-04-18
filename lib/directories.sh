#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

directories()
{
    # Array of common User-Agents
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
    
    # Randomly select a User-Agent
    USER_AGENT=${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]}]}
    
    # Get server headers to detect CDN
    SERVER_INFO=$(curl -s -I "$DOMAIN")
    
    # Define standard legitimate headers
    HEADERS=(
        "User-Agent: $USER_AGENT"
        "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
        "Accept-Language: en-US,en;q=0.5"
        "Accept-Encoding: gzip, deflate, br"
        "Connection: keep-alive"
        "Upgrade-Insecure-Requests: 1"
        "Sec-Fetch-Dest: document"
        "Sec-Fetch-Mode: navigate"
        "Sec-Fetch-Site: none"
        "Sec-Fetch-User: ?1"
        "Cache-Control: max-age=0"
        "DNT: 1"
        "Te: trailers"
    )
    
    # Check for common CDNs and add appropriate headers
    if echo "$SERVER_INFO" | grep -i "cloudflare" > /dev/null; then
        # Add Cloudflare specific headers
        HEADERS+=(
            "CF-IPCountry: US"
            "CF-RAY: $(openssl rand -hex 16)"
        )
        echo -e "${BLUE}[*] Cloudflare CDN detected, adding specific headers${RESET}"
    elif echo "$SERVER_INFO" | grep -i "akamai" > /dev/null; then
        # Add Akamai specific headers
        HEADERS+=(
            "Akamai-Origin-Hop: 1"
        )
        echo -e "${BLUE}[*] Akamai CDN detected, adding specific headers${RESET}"
    elif echo "$SERVER_INFO" | grep -i "fastly" > /dev/null; then
        # Add Fastly specific headers
        HEADERS+=(
            "Fastly-SSL: 1"
        )
        echo -e "${BLUE}[*] Fastly CDN detected, adding specific headers${RESET}"
    elif echo "$SERVER_INFO" | grep -i "amazonaws" > /dev/null || echo "$SERVER_INFO" | grep -i "cloudfront" > /dev/null; then
        # Add AWS/CloudFront specific headers
        HEADERS+=(
            "X-Amz-Cf-Id: $(openssl rand -hex 16)"
        )
        echo -e "${BLUE}[*] AWS/CloudFront CDN detected, adding specific headers${RESET}"
    fi
    
    # Extract cookies properly from response headers with advanced cookie handling
    # Store cookies in a temporary file for processing
    echo "$SERVER_INFO" | grep -i "^set-cookie:" > "$TMP/raw_cookies.txt"
    
    # Process cookies if any were found
    if [ -s "$TMP/raw_cookies.txt" ]; then
        # Extract cookie names and values preserving the format
        COOKIES=$(cat "$TMP/raw_cookies.txt" | sed 's/^[Ss]et-[Cc]ookie: //g' | cut -d';' -f1 | paste -sd '; ')
        
        # Add cookies to headers if available
        if [ -n "$COOKIES" ]; then
            HEADERS+=("Cookie: $COOKIES")
            echo -e "${BLUE}[*] Added cookies: $COOKIES${RESET}"
        fi
    fi
    
    # Convert headers into ffuf parameters
    HEADER_PARAMS=()
    for HEADER in "${HEADERS[@]}"; do
        HEADER_PARAMS+=("-H" "$HEADER")
    done
    
    # Run ffuf with the prepared headers
    echo -e "${BLUE}[*] Starting directory fuzzing for: $DOMAIN${RESET}"
    ffuf -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt \
         -u "$DOMAIN/FUZZ" \
         -ac -c -s \
         -o "$TMP/directories.txt" \
         "${HEADER_PARAMS[@]}"
    
    # Display success message
    echo -e "${GREEN}[+] Successfully fuzzed directories and saved to ${TMP}/directories.txt${RESET}"
    
    # Clean up temporary files
    [ -f "$TMP/raw_cookies.txt" ] && rm "$TMP/raw_cookies.txt"
}
