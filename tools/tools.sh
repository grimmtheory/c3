#!/bin/bash

# Source some cliqr variables and scripts
cliqrroot=/usr/local/osmosix
. $cliqrroot/etc/.osmosix.sh
. $cliqrroot/etc/userenv
. $cliqrroot/service/utils/cfgutil.sh
. $cliqrroot/service/utils/install_util.sh
. $cliqrroot/service/utils/os_info_util.sh

sudo agentSendLogMessage "Starting post-init stuff..."
sudo agentSendLogMessage "Adding cliqruser and centos users to sudoers..."
sudo usermod -aG wheel centos; usermod -aG wheel cliqruser

sudo agentSendLogMessage "Adding a new key to /home/cliqruser/.ssh/authorized_keys..."
echo "## Dynamically inserted key ##" >> /home/cliqruser/.ssh/authorized_keys
echo $my_key >> /home/cliqruser/.ssh/authorized_keys

sudo agentSendLogMessage "Appending /home/cliqruser/.ssh/authorized_keys to /home/centos/.ssh/authorized_keys..."
sudo bash -c "echo $my_key >> /home/centos/.ssh/authorized_keys"

exit 0