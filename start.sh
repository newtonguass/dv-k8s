#/bin/bash
cd terraform
#terraform init terraform plan -out=.tfoutput
#terraform apply .tfoutput
#mkdir -p ../.credential
#terraform output -raw tls_private_key > ../.credential/id_rsa
#chmod 600 ../.credential/id_rsa
k8sMaster_pub_ip=$(terraform output  -json public_ip_address| jq '.[0]' ) 
k8sWorker_pub_ip=$(terraform output  -json public_ip_address| jq '.[1]' ) 
cd ../ansible
ansible-playbook playbook.yml --extra-vars 'runtime=crio k8sMaster_pub_ip='$k8sMaster_pub_ip' k8sWorker_pub_ip='$k8sWorker_pub_ip