FROM alpine:20250108

# Until linuxptp reaches alpine stable
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk --update --no-cache add bash chrony linuxptp
RUN rm /etc/chrony/chrony.conf

# Make sure permissions and ownership are correct already
RUN mkdir -p /var/run/chrony
RUN chown chrony:chrony /var/run/chrony
RUN chmod 750 /var/run/chrony

COPY systemd-stop-unit.bash systemd-stop-unit.bash
COPY start.bash start.bash

CMD ["/bin/bash","start.bash"]
