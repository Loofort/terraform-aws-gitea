#!/usr/bin/env bash

set -euxo pipefail

if [ "$#" -ne 1 ]; then
    echo "usage: $0 name"
    echo "where name is the s3 bucket (and dynamodb table) to be created for tf-remote-state storage"
    exit 1
fi
tfname=$1
tfstate=aws-init/terraform.tfstate

terraform init aws-init

# first, try to import remote storage
terraform import -state=$tfstate -backup=- -config aws-init aws_s3_bucket.bucket $tfname || true
terraform import -state=$tfstate -backup=- -config aws-init aws_dynamodb_table.table $tfname || true

# create remote storage
terraform apply -auto-approve -state=$tfstate -backup=- -var "name=$tfname" aws-init

# to destroy (firstly set: prevent_destroy = false) :
#terraform apply -auto-approve -state=$tfstate -backup=- -var "name=$tfname" -var "destroy=true" aws-init
#terraform destroy -auto-approve -state=$tfstate -backup=- -var "name=$tfname" aws-init

# init actual backend with proper remote storage 
terraform init \
    -backend-config="bucket=$tfname" \
    -backend-config="key=gitea/terraform.tfstate" \
    -backend-config="dynamodb_table=$tfname"
