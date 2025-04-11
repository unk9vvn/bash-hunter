#!/bin/bash

parameters()
{
    x8 --url $DOMAIN \
    -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt \
    -o $TMP/hidden-params.txt 2>/dev/null
}