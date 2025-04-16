#!/bin/bash

ports()
{
    naabu -list $TMP/subdomains.txt -silent -o $TMP/port_one.txt
    cat $TMP/subdomains.txt | while read domain; do
        if ping -c 1 $domain &> /dev/null; then
            rustscan_output=$(rustscan -a $domain --ulimit 5000 -- -Pn -T4 -n 2>&1)
            if echo "$rustscan_output" | grep -q "PORT"; then
                echo "$rustscan_output" | grep -E "^[0-9]+/tcp" | awk '{print $1}' | cut -d "/" -f1 | while read port_number; do
                    echo "$domain:$port_number" >> $TMP/port_one.txt
                done
            fi
        fi
    done
    httpx -l $TMP/port_one.txt -resolve -silent -o $TMP/port_two.txt
    cat $TMP/port_two.txt | sort -u | anew $TMP/port_three.txt > $TMP/ports.txt
    rm -f $TMP/port_one.txt $TMP/port_two.txt $TMP/port_three.txt
    echo -e "${RED}[-] Success FUZZ and SAVE ${TMP}/ports.txt ${RESET}"
}
