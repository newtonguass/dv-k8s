#/bin/bash
VBoxManage list vms | awk '{print $1}'| grep k8s | grep -v node2 | xargs -n1 -i VBoxManage startvm {} --type headless
