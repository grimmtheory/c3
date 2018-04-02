#!/bin/bash
agentSendLogMessage "Starting post-init stuff..."

agentSendLogMessage "Adding cliqruser to /etc/sudoers..."
echo "cliqruser  ALL= NOPASSWD: ALL" >> /etc/sudoers
agentSendLogMessage "Last line of /etc/sudoers"
agentSendLogMessage `tail -n 1 /etc/sudoers`

agentSendLogMessage "Adding a new key to /home/$my_user/.ssh/authorized_keys..."
echo $my_key >> /home/$my_user/.ssh/authorized_keys

agentSendLogMessage "Appending /home/cliqruser/.ssh/authorized_keys to /home/centos/.ssh/authorized_keys..."
echo "cliqruser  ALL= NOPASSWD: ALL" >> /etc/sudoers

exit 0