#/bin/bash
cd terraform
terraform init
terraform plan -out=.tfoutput
terraform apply .tfoutput
mkdir -p ../.credential
terraform output -raw tls_private_key > ../.credential/id_rsa
chmod 600 ../.credential/id_rsa
k8sMaster_pub_ip=$(terraform output  -json public_ip_address| jq '.[0]' ) 
cd ../ansible
while true
do
    if timeout 10 bash -c '</dev/tcp/'$k8sMaster_pub_ip'/22 &>/dev/null'
    then
    echo 'Port is open, start to run ansible playbook'
    break
    else
    echo 'Port is closed, waitting...'
    fi
done
ansible-playbook playbook.yml --extra-vars 'k8sMaster_pub_ip='$k8sMaster_pub_ip