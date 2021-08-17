FROM balenalib/generic-alpine:latest

RUN apk --update --no-cache add chrony && \
  rm -rf /var/cache/apk/*
  #/etc/chrony
#   touch /var/lib/chrony/chrony.drift && \
#   chown chrony:chrony -R /var/lib/chrony

COPY start.bash start.bash

# CMD ["chronyd","-d","-s","-f","${CONFIG:-"/etc/chrony.conf"}"]
CMD ["/bin/bash","start.bash"]
