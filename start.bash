#!/bin/bash

if [ -z "$CONFIG_FILE" ]
then
    if [ -z "$CONFIG_FILE_CONTENT" ]
    then
        echo "Either CONFIG_FILE or CONFIG_FILE_CONTENT needs to be set as environment variable"
        exit 1
    else
        CONFIG_FILE=/config.conf
        echo -e "$CONFIG_FILE_CONTENT" > "$CONFIG_FILE"
    fi
fi

echo "Config file content:"
cat "$CONFIG_FILE"

echo "Disabling chrony on balena host:"
./systemd-stop-unit.bash chronyd.service -1  # Wait until balena chrony is stopped
./systemd-stop-unit.bash chronyd.service 60 &  # Retry every minute just to be sure

# Make sure permissions and ownership are correct at startup, apperently this can get screwed up
mkdir -p /var/run/chrony
chown chrony:chrony /var/run/chrony
chmod 750 /var/run/chrony

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
