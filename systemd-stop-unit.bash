#!/bin/sh

# Inspired by: https://github.com/balena-io-experimental/balena-gateway-config

function wait_for_dbus() {
    echo "Waiting for DBus to be ready"
	while true; do
		dbus-send --system \
			  --print-reply \
			  --dest=org.freedesktop.DBus \
			  /org/freedesktop/DBus \
			  org.freedesktop.DBus.ListNames

		if [ $? ]; then
			break;
		else
			sleep 0.1
		fi
	done

	echo "DBus is now accepting connections"
}

UNIT_NAME=$1
SLEEP_DURATION=$2

if [ -z "$UNIT_NAME" ]; then
	echo "Usage: ./systemd-stop-unit.sh [unit name] [sleep_duration]"
	echo "  sleep_duration: Number of seconds to sleep when unit becomes inactive (default: -1)"
	echo "                  Use 0 or negative value to exit immediately"
	exit 1
fi

# Set default behavior if no second argument provided
if [ -z "$SLEEP_DURATION" ]; then
	SLEEP_DURATION="-1"
fi

wait_for_dbus

unit_path=$(dbus-send --system \
		      --print-reply \
		      --type=method_call \
		      --dest=org.freedesktop.systemd1 \
		      /org/freedesktop/systemd1 \
		      org.freedesktop.systemd1.Manager.GetUnit string:$UNIT_NAME \
		      | awk '/object path/ {gsub("\"", "", $3); print $3}')

last_active_state=""
while true; do
	active_state=$(dbus-send --system \
				 --print-reply \
				 --dest=org.freedesktop.systemd1 \
				 $unit_path \
				 org.freedesktop.DBus.Properties.Get \
					string:org.freedesktop.systemd1.Unit \
					string:ActiveState \
				 | awk '/variant/ {gsub("\"","",$3); print $3}')
	if [ "$last_active_state" != "$active_state" ]; then
		echo "Unit $UNIT_NAME is now $active_state"
	fi
	if [ "$active_state" = "inactive" ]; then
		if [ "$SLEEP_DURATION" -le 0 ]; then
			echo "Unit $UNIT_NAME is inactive, exiting immediately"
			break
		else
			sleep "$SLEEP_DURATION"
			break
		fi
	else
		dbus-send --system \
			  --type=method_call \
			  --dest=org.freedesktop.systemd1 \
			  /org/freedesktop/systemd1 \
			  org.freedesktop.systemd1.Manager.StopUnit \
			  string:$UNIT_NAME string:replace
		echo "Stopping unit $UNIT_NAME"
	fi
	last_active_state="$active_state"
	sleep 1.0
done
