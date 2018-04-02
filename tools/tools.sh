#!/bin/bash

cat <<EOF >/home/cliqruser/post-init.sh
# Source some cliqr variables and scripts
sudo . /usr/local/osmosix/etc/.osmosix.sh
sudo . /usr/local/osmosix/etc/userenv
sudo . /usr/local/osmosix/service/utils/cfgutil.sh
sudo . /usr/local/osmosix/service/utils/agent_util.sh

sudo agentSendLogMessage "Starting post-init stuff..."

sudo agentSendLogMessage "Adding cliqruser and centos users to sudoers..."
sudo usermod -aG wheel centos; usermod -aG wheel cliqruser

sudo agentSendLogMessage "Adding a new key to /home/$my_user/.ssh/authorized_keys..."
sudo echo "## Dynamically inserted key ##" >> /home/$my_user/.ssh/authorized_keys
sudo echo $my_key >> /home/$my_user/.ssh/authorized_keys

sudo agentSendLogMessage "Appending /home/cliqruser/.ssh/authorized_keys to /home/centos/.ssh/authorized_keys..."
sudo echo "" >> /home/$centos/.ssh/authorized_keys
sudo echo "## Copied over keys ##" >> /home/centos/.ssh/authorized_keys
sudo cat /home/cliqruser/.ssh/authorized_keys >> /home/centos/.ssh/authorized_keys
EOF

cd /home/cliqruser
chmod +x ./post-init.sh
./post-init.sh

exit 0