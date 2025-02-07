FROM alpine:latest

RUN apk add --no-cache \
    git \
    helm \
    curl \
    bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]