# Damn Vulnerable kubernetes
- This K8S IaC template is to create a very vulnerable K8S application for testing purpose, do not use it in any production environment.
- The K8S IaC involves several parts:
    1. Terraform IaC for Node provision
    1. Ansible playbook for K8S bootstrap
    1. A tweak GUI for the vulnerable configuration purpose

## Node provision
- Currently rely on Azure environment