#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

subdomains()
{
    subfinder -d $DOMAIN -all -recursive -silent -o $TMP/sub_one.txt
    curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' >> $TMP/sub_one.txt
    httpx -l $TMP/sub_one.txt -resolve -silent -o $TMP/sub_two.txt
    cat $TMP/sub_two.txt | sort -u | anew $TMP/sub_three.txt > $TMP/subdomains.txt
    rm -f $TMP/sub_one.txt $TMP/sub_two.txt $TMP/sub_three.txt
    echo -e "${RED}[-] Success FUZZ and SAVE ${TMP}/subdomains.txt ${RESET}"
}
