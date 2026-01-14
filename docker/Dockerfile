FROM ghcr.io/flant/shell-operator:v1.12.4

RUN apk --no-cache add jq

RUN adduser -S controller

RUN chown -R controller "/hooks" &&  \
    mkdir /var/run/shell-operator &&  \
    chown -R controller "/var/run/shell-operator"

USER controller

COPY hooks /hooks
