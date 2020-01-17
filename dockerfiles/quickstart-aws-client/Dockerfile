FROM python:3-alpine

RUN apk add --no-cache bash ca-certificates curl && \
  pip3 install awscli

COPY ./config /root/.aws/config
COPY ./credentials /root/.aws/credentials

# Specify the "cacert" trust stoire to Python
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# Regenerate the "cacert" trust store at each startup
ENTRYPOINT update-ca-certificates && sleep infinity
