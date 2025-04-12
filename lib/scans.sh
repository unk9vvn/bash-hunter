#!/bin/bash

nuclei()
{
    nuclei -t /usr/share/bash-hunter/nuclei -tags all -v -u $DOMAIN
}