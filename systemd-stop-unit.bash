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

if [ -z "$UNIT_NAME" ]; then
	echo "Usage: ./systemd-stop-unit.sh [unit name]"
fi

wait_for_dbus

unit_path=$(dbus-send --system \
		      --print-reply \
		      --type=method_call \
		      --dest=org.freedesktop.systemd1 \
		      /org/freedesktop/systemd1 \
		      org.freedesktop.systemd1.Manager.GetUnit string:$UNIT_NAME \
		      | awk '/object path/ {gsub("\"", "", $3); print $3}')

while true; do
	active_state=$(dbus-send --system \
				 --print-reply \
				 --dest=org.freedesktop.systemd1 \
				 $unit_path \
				 org.freedesktop.DBus.Properties.Get \
					string:org.freedesktop.systemd1.Unit \
					string:ActiveState \
				 | awk '/variant/ {gsub("\"","",$3); print $3}')

	if [ "$active_state" = "inactive" ]; then
		echo "Unit $UNIT_NAME is now $active_state"
		break;
	else
		dbus-send --system \
			  --type=method_call \
			  --dest=org.freedesktop.systemd1 \
			  /org/freedesktop/systemd1 \
			  org.freedesktop.systemd1.Manager.StopUnit \
			  string:$UNIT_NAME string:replace
	fi
done
