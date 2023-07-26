#!/bin/bash

# Check if chrony socket dir is owned by chrony user and group
if [ "$(stat -c '%U' /var/run/chrony)" != "chrony" ] || [ "$(stat -c '%G' /var/run/chrony)" != "chrony" ]; then
    echo "Chrony socket dir is not owned by chrony user, changing ownership"
    chown chrony:chrony /var/run/chrony
fi

# Check if chrony socket dir has correct permissions
if [ "$(stat -c '%a' /var/run/chrony)" != 750 ]; then
    echo "Chrony socket dir has incorrect permissions, changing permissions"
    chmod 750 /var/run/chrony
fi
