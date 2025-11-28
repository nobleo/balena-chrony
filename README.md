# balena-chrony

<https://github.com/nobleo/balena-chrony>

Balena doesn't allow modifying the `/etc/chrony/chrony.conf` file.

This image disables the chrony-config and runs an instance of chrony for which the config can be modified.

## Usage

Example usage in a docker-compose file, where port 323 is forwarded to be able to communicate with chronyd from outside the container:

```yaml
services:
  balena-chrony:
    image: nobleo/balena-chrony
    cap_add:
      - SYS_TIME
    labels:
      io.balena.features.dbus: '1'
    ports:
      - "323:323/udp"
    environment:
      DBUS_SYSTEM_BUS_ADDRESS: unix:path=/host/run/dbus/system_bus_socket
      CONFIG_FILE_CONTENT: |
        pool pool.ntp.org iburst
        initstepslew 10 pool.ntp.org
        driftfile /data/chrony.drift
        rtcsync
        cmdport 0
```

### Advanced usage

You can also share the chronyd socket via docker volume mounts to give other services full control of chrony.
For example, execute a `chronyc makestep` from within another container:

```yaml
services:
  balena-chrony:
    image: nobleo/balena-chrony
    cap_add:
      - SYS_TIME
    labels:
      io.balena.features.dbus: '1'
    volumes:
      - "chrony-socket-dir:/var/run/chrony/"
    environment:
      DBUS_SYSTEM_BUS_ADDRESS: unix:path=/host/run/dbus/system_bus_socket
      CONFIG_FILE_CONTENT: |
        pool pool.ntp.org iburst
        initstepslew 10 pool.ntp.org
        driftfile /data/chrony.drift
        rtcsync
        cmdport 0
  other-container:
    image: some_image/with_chronyc_installed
    volumes:
      - "chrony-socket-dir:/var/run/chrony/"

volumes:
  chrony-socket-dir: {}
```

### PTP with NTP Synchronisation

To enable PTP synchronisation we can leverage the `timemaster` daemon.
This uses ptp4l and phc2sys in combination with chronyd to synchronize the system clock to NTP and PTP time sources ([examples](https://www.redhat.com/en/blog/combining-ptp-ntp-get-best-both-worlds)).

```yaml
services:
  balena-chrony:
    image: nobleo/balena-chrony
    network_mode: host  # Required for PTP
    cap_add:
      - SYS_TIME
    labels:
      io.balena.features.dbus: '1'
    ports:
      - "323:323/udp"
    environment:
      DBUS_SYSTEM_BUS_ADDRESS: unix:path=/host/run/dbus/system_bus_socket
      TIME_SYNC_DAEMON: timemaster
      CONFIG_FILE_CONTENT: |
        [ptp_domain 0]
        interfaces eth0

        [ntp_server ntp.example.com]
```

## See also

<https://github.com/nobleo/avahi-alias-balena.git>
