# balena-chrony

Balena doesn't allow modifying the `/etc/chrony/chrony.conf` file.

This image disables the chrony-config and runs an instance of chrony for which the config can be modified.

## Usage

Example usage in a docker-compose file:

```yaml
  balena-chrony:
    image: nobleo/balena-chrony
    cap_add:
      - SYS_TIME
    labels:
      io.balena.features.dbus: '1'
    environment:
      DBUS_SYSTEM_BUS_ADDRESS: unix:path=/host/run/dbus/system_bus_socket
      CONFIG_FILE_CONTENT: |
        pool pool.ntp.org iburst
        initstepslew 10 pool.ntp.org
        driftfile /var/lib/chrony/chrony.drift
        rtcsync
        cmdport 0
```

## See also
https://github.com/nobleo/balena-chrony.git
