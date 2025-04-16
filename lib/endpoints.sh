#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

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
    gau $DOMAIN --o $TMP/endpoint_two.txt

    # 3. waybackurls
    waybackurls $DOMAIN > $TMP/endpoint_three.txt

    # 4. hakrawler
    echo $DOMAIN | hakrawler -subs -depth 2 -plain -insecure > $TMP/endpoint_four.txt

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
    sort -u | anew $TMP/endpoints.txt
    echo -e "${RED}[-] Success FUZZ and SAVE ${TMP}/endpoints.txt ${RESET}"
}
