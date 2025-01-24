FROM ghcr.io/flant/shell-operator:v1.5.3

RUN apk --no-cache add curl

RUN adduser -S controller

RUN chown -R controller "/hooks" &&  \
    mkdir /var/run/shell-operator &&  \
    chown -R controller "/var/run/shell-operator"

USER controller

COPY hooks /hooks
