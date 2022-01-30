#!/bin/bash
terraform init
terraform plan -out=.tfoutput
terraform apply .tfoutput
terraform output -raw tls_private_key > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
