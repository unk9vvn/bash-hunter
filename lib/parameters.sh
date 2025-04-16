#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

parameters()
{
    x8 --url $DOMAIN \
       -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt \
       -o $TMP/hidden-params.txt
}
