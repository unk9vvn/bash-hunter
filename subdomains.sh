#!/bin/bash

subdomains()
{
    subfinder -d $DOMAIN -all -recursive -silent -o $TMP/sub_one.txt
    curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' >> $TMP/sub_one.txt
    httpx -l $TMP/sub_one.txt -resolve -silent -o $TMP/sub_two.txt
    cat $TMP/sub_two.txt | sort -u | anew $TMP/sub_three.txt > $TMP/subdomains.txt
    rm -f $TMP/sub_one.txt $TMP/sub_two.txt $TMP/sub_three.txt
    echo -e "${RED}[-] Success FUZZ and SAVE ${TMP}/subdomains.txt ${RESET}"
}