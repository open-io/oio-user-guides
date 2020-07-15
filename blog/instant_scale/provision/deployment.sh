#!/bin/bash

set -eux -o pipefail

# Deployment
yum install git python3 sshpass -y
git clone https://github.com/open-io/ansible-playbook-openio-deployment.git --branch 20.04 /home/vagrant/oiosds

pushd /home/vagrant/oiosds/products/sds
python3 -m venv openio_venv
. openio_venv/bin/activate
pip install -r ansible.pip
cp /vagrant/inventory* .
./requirements_install.sh
popd
chown vagrant: -R /home/vagrant/oiosds

# awscli (for demo)
yum install awscli -y
mkdir /home/vagrant/.aws
cat > /home/vagrant/.aws/config <<EOF
[default]
s3 =
   signature_version = s3v4
   max_concurrent_requests = 10
   max_queue_size = 100
region = us-east-1
ca_bundle = /etc/ssl/certs/rootCA.pem
EOF

cat > /home/vagrant/.aws/credentials <<EOF
[default]
aws_access_key_id = TENANT1:user1
aws_secret_access_key = USER11_PASS

[tenant1_user1]
aws_access_key_id = TENANT1:user1
aws_secret_access_key = USER11_PASS

[tenant1_user2]
aws_access_key_id = TENANT1:user2
aws_secret_access_key = USER12_PASS

[tenant2_user1]
aws_access_key_id = TENANT2:user1
aws_secret_access_key = USER21_PASS
EOF
chown vagrant: -R /home/vagrant/.aws
