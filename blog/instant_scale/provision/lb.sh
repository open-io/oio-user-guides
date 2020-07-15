#!/bin/bash

set -eux -o pipefail

groupadd -g 2001 traefik
useradd -g traefik --no-user-group --no-create-home --shell /usr/sbin/nologin --system --uid 2001 traefik

# certificates 
curl -sSL -o /usr/bin/mkcert https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64
chmod a+x /usr/bin/mkcert
mkdir /etc/ssl/private_keys
mkcert -key-file /etc/ssl/private_keys/openio.pem -cert-file /etc/ssl/certs/openio.cert \
  192.168.4.200 vagrant.demo.openio.io s3.openio.io sds.openio.io localhost 127.0.0.1 
chown traefik: /etc/ssl/private_keys/openio.pem
cp /root/.local/share/mkcert/rootCA.pem /etc/ssl/certs/
echo 192.168.4.200 vagrant.demo.openio.io >> /etc/hosts

# LB
wget --quiet https://github.com/containous/traefik/releases/download/v2.2.1/traefik_v2.2.1_linux_amd64.tar.gz
tar -xzf traefik_v2.2.1_linux_amd64.tar.gz
cp traefik /usr/bin/
rm -f CHANGELOG.md LICENSE.md traefik traefik.*tar.gz
install -d -o traefik -g traefik -m 750 /etc/traefik.d

cat > /etc/systemd/system/traefik.service <<EOF
[Unit]
Description=Traefik
Documentation=https://docs.traefik.io
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service
AssertFileIsExecutable=/usr/bin/traefik
AssertPathIsDirectory=/etc/traefik.d

[Service]
Type=notify
Restart=on-abnormal

User=traefik
Group=traefik

EnvironmentFile=/etc/sysconfig/traefik
ExecStart=/usr/bin/traefik

; Give the traefik binary the ability to bind to privileged ports (e.g. 80, 443) as a non-root user
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/sysconfig/traefik <<EOF
TRAEFIK_ACCESSLOG=true
TRAEFIK_PROVIDERS_FILE_DIRECTORY="/etc/traefik.d"

TRAEFIK_API_DASHBOARD=true
TRAEFIK_API=true
TRAEFIK_LOG_LEVEL=INFO
#TRAEFIK_LOG_LEVEL=DEBUG

# ENTRYPOINTS
TRAEFIK_ENTRYPOINTS_TRAEFIK_ADDRESS="192.168.4.200:8081"
#TRAEFIK_ENTRYPOINTS_S3_ADDRESS=":6007"
TRAEFIK_ENTRYPOINTS_S3TLS_ADDRESS="192.168.4.200:443"

TRAEFIK_PROVIDERS_DOCKER=false

EOF

cat > /etc/traefik.d/dashboard.yml <<EOF
http:
  routers:
    dashboard:
      rule: HostRegexp(\`{host:.+}\`)
      tls: {}
      entryPoints:
        - traefik
      service: api@internal

EOF

cat > /etc/traefik.d/openio.yml <<EOF
tls:
  stores:
    default:
      defaultCertificate:
        certFile: /etc/ssl/certs/openio.cert
        keyFile: /etc/ssl/private_keys/openio.pem

http:
  routers:
    s3-gateway-websecure:
      rule: HostRegexp(\`{host:.+}\`)
      tls: {}
      entryPoints:
        #- s3
        - s3tls
      service: s3-gateway-svc

  services:
    s3-gateway-svc:
      loadBalancer:
        healthCheck:
          path: /healthcheck
          interval: "10s"
          timeout: "3s"
        servers:
          - url: http://192.168.4.10:6007/
          - url: http://192.168.4.20:6007/
          - url: http://192.168.4.30:6007/

EOF

systemctl daemon-reload
systemctl start traefik.service
systemctl enable traefik.service
