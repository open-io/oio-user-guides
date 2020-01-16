FROM python:3-alpine

RUN apk add --no-cache bash ca-certificates curl && \
  pip3 install awscli

COPY ./config /root/.aws/config
COPY ./credentials /root/.aws/credentials

# Regenrate ca-cert before startup
ENTRYPOINT update-ca-certificates && sleep infinity
