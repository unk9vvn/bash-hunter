#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

nuclei()
{
    nuclei -t /usr/share/bash-hunter/nuclei -tags all -v -u $DOMAIN
}
