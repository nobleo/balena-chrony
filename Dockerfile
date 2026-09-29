FROM alpine:3.23

# Until linuxptp reaches alpine stable
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk --update --no-cache add bash chrony dbus linuxptp
RUN rm /etc/chrony/chrony.conf

COPY systemd-stop-unit.bash systemd-stop-unit.bash
COPY start.bash start.bash

CMD ["/bin/bash","start.bash"]
