#!/usr/bin/env bash

set -euxo pipefail

#ip=$(terraform output -json | jq -r '.public_ip.value')
#terraform output -json | jq -r '.private_key.value' > key.pem
ip=$(terraform state show aws_instance.host | grep "public_ip " | sed 's/public_ip *= //')
terraform state show tls_private_key.key | perl -ne 'BEGIN{undef $/;} /(-----BEGIN RSA PRIVATE.*?PRIVATE KEY-----)/s and print "$1"' > key.pem

chmod 400 key.pem
ssh -i key.pem -oStrictHostKeyChecking=no ec2-user@$ip
rm -f key.pem

# generate key manually 
# ssh-keygen -t rsa -b 4096 -C "skarbdev@gmail.com" -f sshkey -q -N ""