#!/bin/bash

if [ -z "$CONFIG_FILE" ]
then
    if [ -z "$CONFIG_FILE_CONTENT" ]
    then
        echo "Either CONFIG_FILE or CONFIG_FILE_CONTENT needs to be set as environment variable"
        exit 1
    else
        CONFIG_FILE=chrony.conf
        echo "$CONFIG_FILE_CONTENT" > "chrony.conf"
    fi
fi

echo "Disabling chrony on balena host:"
./systemd-stop-unit.bash chronyd.service

echo "Config file content:"
cat "$CONFIG_FILE"

chronyd -d -s -f "$CONFIG_FILE"
