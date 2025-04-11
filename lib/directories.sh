#!/bin/bash

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