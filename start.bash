#!/bin/bash

if [ -z "$CONFIG_FILE" ]
then
    if [ -z "$CONFIG_FILE_CONTENT" ]
    then
        echo "Either CONFIG_FILE or CONFIG_FILE_CONTENT needs to be set as environment variable"
        exit 1
    else
        CONFIG_FILE=/config.conf
        echo "$CONFIG_FILE_CONTENT" > "$CONFIG_FILE"
    fi
fi

echo "Disabling chrony on balena host:"
./systemd-stop-unit.bash chronyd.service

echo "Config file content:"
cat "$CONFIG_FILE"

: "${TIME_SYNC_DAEMON:=chronyd}"  # Default to chronyd if unset or empty

if [ "$TIME_SYNC_DAEMON" = "chronyd" ];
then
    chronyd -d -s -f "$CONFIG_FILE"
elif [ "$TIME_SYNC_DAEMON" = "timemaster" ];
then
    timemaster -f "$CONFIG_FILE"
else
    "$TIME_SYNC_DAEMON"  # Just run the specified daemon
fi
