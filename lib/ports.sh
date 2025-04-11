#!/bin/bash

ports()
{
    naabu -list $TMP/subdomains.txt -silent -o $TMP/port_one.txt
    httpx -l $TMP/port_one.txt -resolve -silent -o $TMP/port_two.txt
    cat $TMP/port_two.txt | sort -u | anew $TMP/port_three.txt > $TMP/ports.txt
    rm -f $TMP/port_one.txt $TMP/port_two.txt $TMP/port_three.txt
    echo -e "${RED}[-] Success FUZZ and SAVE ${TMP}/ports.txt ${RESET}"
}