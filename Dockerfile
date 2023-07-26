FROM balenalib/generic-alpine:latest

RUN apk --update --no-cache add chrony
RUN rm /etc/chrony/chrony.conf

COPY systemd-stop-unit.bash systemd-stop-unit.bash
COPY start.bash start.bash

CMD ["/bin/bash","start.bash"]
