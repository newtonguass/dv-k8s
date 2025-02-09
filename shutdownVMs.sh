#/bin/bash
VBoxManage list runningvms | awk '{print $1}' | xargs -n1 -i VBoxManage controlvm {} poweroff
