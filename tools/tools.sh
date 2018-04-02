#!/bin/bash
# Source some cliqr variables and scripts
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

agentSendLogMessage "Starting post-init stuff..."

agentSendLogMessage "Adding cliqruser and centos users to sudoers..."
usermod -aG wheel centos; usermod -aG wheel cliqruser

agentSendLogMessage "Adding a new key to /home/$my_user/.ssh/authorized_keys..."
echo "## Dynamically inserted key" >> /home/$my_user/.ssh/authorized_keys
echo $my_key >> /home/$my_user/.ssh/authorized_keys

agentSendLogMessage "Appending /home/cliqruser/.ssh/authorized_keys to /home/centos/.ssh/authorized_keys..."
echo "" >> /home/$centos/.ssh/authorized_keys
echo "## Copied over keys ##" >> /home/centos/.ssh/authorized_keys
cat /home/cliqruser/.ssh/authorized_keys >> /home/centos/.ssh/authorized_keys

exit 0