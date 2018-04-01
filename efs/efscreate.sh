#!/bin/bash
# Title		: efscreate.sh
# Description	: Lifecycle action script for creating AWS efs file systems.
# Author	: jasgrimm
# Date		: 2018-04-01
# Version	: 0.1
# Usage		: bash efscreate.sh
# External Vars	: Read in at run time - $PERFORMANCE_MODE, $EFS_TOKEN, $AWS_REGION, $AWS_ACCESS_KEY_ID, and $AWS_SECRET_ACCESS_KEY
# Internal Vars	: Initialized within srcipt - $AWS_INSTALL_DIR, $AWS_CONFIG_DIR, $AWS_CONFIG_FILE, $AWS_CRED_FILE

# If running as an "external-service", execute and terminate docker container on the orchestrator
# . /utils.sh
# print_log "$(env)"

# If running within a virtual machine (default)
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

# Declare / configure internal vars
AWS_INSTALL_DIR="/usr/local/aws"
PATH=$PATH:$AWS_INSTALL_DIR/bin
AWS_CONFIG_DIR="/root/.aws"
AWS_CONFIG_FILE="$AWS_CONFIG_DIR/config"
AWS_CRED_FILE="$AWS_CONFIG_DIR/credentials"
AWS_EFS_FILE_JSON="/root/efslist.json.txt"
AWS_EFS_FILE_PRETTY="/root/efslist.pretty.txt"

# Install prerequisites
installPrerequisites() {
	agentSendLogMessage "Installing prerequisites..."
	if [ -f /bin/jq ]; then
		agentSendLogMessage "JQ is already installed, skipping install."
	else
		agentSendLogMessage "JQ is not installed, installing now."
		yum -y --skip-broken install jq
	fi
}

# Functions
installAWSCli() {
    agentSendLogMessage "Installing AWS CLI tools..."

        if [ -f $AWS_INSTALL_DIR/bin/aws ]; then
            agentSendLogMessage  "AWS CLI already installed, skipping the AWS CLI Install."
        else
            mkdir -p $AWS_INSTALL_DIR; cd $AWS_INSTALL_DIR
            wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip; unzip awscli-bundle.zip
            ./awscli-bundle/install -i $AWS_INSTALL_DIR
            agentSendLogMessage  "AWS CLI tools are now installed."
        fi
}

configureAWSCli() {
	agentSendLogMessage "Configuring AWS CLI tools..."

	mkdir -p $AWS_CONFIG_DIR

	echo "[default]" > $AWS_CONFIG_FILE
	echo "region = $AWS_REGION" >> $AWS_CONFIG_FILE
	chmod 600 $AWS_CONFIG_FILE

	echo "[default]" > $AWS_CRED_FILE
	echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> $AWS_CRED_FILE
	echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> $AWS_CRED_FILE
	chmod 600 $AWS_CRED_FILE
}

createAWSEfs() {
	agentSendLogMessage "Creating AWS EFS file system with command: $AWS_INSTALL_DIR/bin/aws efs create-file-system --performance-mode $PERFORMANCE_MODE --no-encrypted --creation-token $CREATION_TOKEN"

	$AWS_INSTALL_DIR/bin/aws efs create-file-system --performance-mode $PERFORMANCE_MODE --no-encrypted --creation-token $CREATION_TOKEN
	$AWS_INSTALL_DIR/bin/aws efs describe-file-systems >  > $AWS_EFS_FILE_JSON
	agentSendLogMessage "JSON Format"
	agentSendLogMessage `cat $AWS_EFS_FILE_JSON`
}

# Main
agentSendLogMessage "** EFS File System Create Service Starting **"

installPrerequisites
installAWSCli
configureAWSCli
createAWSEfs

agentSendLogMessage "** EFS File System Create Service Complete **"

exit 0