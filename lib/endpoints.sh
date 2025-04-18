#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

extract_endpoints() {
    echo -e "${BLUE}[+] Crawling with katana...${RESET}"
    katana -u "$domain" \
        -fr "(static|assets|img|images|css|fonts|icons|js|cdn|vendor|bootstrap)/" \
        -o "$tmp_dir/katana.txt" \
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

    echo -e "${BLUE}[+] Collecting with gau...${RESET}"
    gau "$domain" --o "$tmp_dir/gau.txt"

    echo -e "${BLUE}[+] Collecting with waybackurls...${RESET}"
    waybackurls "$domain" > "$tmp_dir/wayback.txt"

    echo -e "${BLUE}[+] Collecting with hakrawler...${RESET}"
    echo "$domain" | hakrawler -subs -depth 2 -plain -insecure > "$tmp_dir/hakrawler.txt"

    echo -e "${BLUE}[+] Merging all URLs...${RESET}"
    cat "$tmp_dir"/*.txt | sort -u > "$tmp_dir/all_raw.txt"

    echo -e "${BLUE}[+] Extracting endpoints without params...${RESET}"
    grep -v '?' "$tmp_dir/all_raw.txt" | \
    sed 's/\?.*//g' | \
    sed 's/\.aspx$//' | \
    sed 's/\/[^/]*\.json$//' | \
    grep -vE '\.(js|css|jpg|png|jpeg|svg|woff|woff2|ttf|eot|mp4|mp3|ico)$' | \
    grep -v '&amp' | \
    sort -u > $tmp_dir/endpoints.txt

    echo -e "${BLUE}[+] Extracting endpoints with params...${RESET}"
    grep '?' "$tmp_dir/all_raw.txt" | sort -u > $tmp_dir/endpoints_with_params.txt

    echo -e "${RED}[-] DONE. Output files:${RESET}"
    echo -e "${GREEN}[+] ${tmp_dir}/endpoints.txt"
    echo -e "${GREEN}[+] ${tmp_dir}/endpoints_with_params.txt"
}
