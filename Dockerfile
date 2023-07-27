FROM balenalib/generic-alpine:latest

RUN apk --update --no-cache add chrony
RUN rm /etc/chrony/chrony.conf

# Make sure permissions and ownership are correct already
RUN mkdir -p /var/run/chrony
RUN chown chrony:chrony /var/run/chrony
RUN chmod 750 /var/run/chrony

COPY systemd-stop-unit.bash systemd-stop-unit.bash
COPY start.bash start.bash

CMD ["/bin/bash","start.bash"]
