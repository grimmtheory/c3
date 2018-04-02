#!/bin/bash
# Title		: efsdelete.sh
# Description	: Lifecycle action script for creating AWS efs file systems.
# Author	: jasgrimm
# Date		: 2018-04-01
# Version	: 0.1
# Usage		: bash efsdelete.sh
# External Vars	: Read in at run time - $EFS_ID, $EFS_TOKEN, $AWS_REGION, $AWS_ACCESS_KEY_ID, and $AWS_SECRET_ACCESS_KEY
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
	agentSendLogMessage "Checking for jq and bc..."

	if [ -f /bin/jq ]; then
		agentSendLogMessage "jq is already installed, skipping install."
	else
		agentSendLogMessage "jq is not installed, installing now."
		yum -y --skip-broken install jq
	fi

	if [ -f /bin/bc ]; then
		agentSendLogMessage "bc is already installed, skipping install."
	else
		agentSendLogMessage "bc is not installed, installing now."
		yum -y --skip-broken install bc
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

deleteAWSEfs() {
	agentSendLogMessage "Deleting AWS EFS file system with command: $AWS_INSTALL_DIR/bin/aws efs delete-file-system --file-system-id $EFS_ID"
	$AWS_INSTALL_DIR/bin/aws efs delete-file-system --file-system-id $EFS_ID
	$AWS_INSTALL_DIR/bin/aws efs describe-file-systems > $AWS_EFS_FILE_JSON
	agentSendLogMessage "AWS EFS file system delete Complete."
	sleep 10
}

listAWSEfs() {
	agentSendLogMessage "Listing AWS EFS file systems with command: $AWS_INSTALL_DIR/bin/aws efs describe-file-systems"

	$AWS_INSTALL_DIR/bin/aws efs describe-file-systems > $AWS_EFS_FILE_JSON
	agentSendLogMessage "JSON Format"
	agentSendLogMessage `cat $AWS_EFS_FILE_JSON`

	agentSendLogMessage "List Format"
	echo "" > $AWS_EFS_FILE_PRETTY
	loopcount=0
	efscount=`cat $AWS_EFS_FILE_JSON | grep FileSystemId | wc -l`
	while [ $loopcount -lt $efscount ]; do
		efsid=`cat $AWS_EFS_FILE_JSON | jq '.FileSystems['"$loopcount"'].FileSystemId'`
		efsperformancemode=`cat $AWS_EFS_FILE_JSON | jq '.FileSystems['"$loopcount"'].PerformanceMode'`
		efscreatetime=`cat $AWS_EFS_FILE_JSON | jq '.FileSystems['"$loopcount"'].CreationTime'`; efscreatetime=`date -d @$efscreatetime | awk '{ print $1 "." $2 "." $3 "." $4 "." $5 }'`
		efsstate=`cat $AWS_EFS_FILE_JSON | jq '.FileSystems['"$loopcount"'].LifeCycleState'`
		efsencryption=`cat $AWS_EFS_FILE_JSON | jq '.FileSystems['"$loopcount"'].Encrypted'`
		efsownerid=`cat $AWS_EFS_FILE_JSON | jq '.FileSystems['"$loopcount"'].OwnerId'`
		efstargets=`cat $AWS_EFS_FILE_JSON | jq '.FileSystems['"$loopcount"'].NumberOfMountTargets'`
		efscreationtoken=`cat $AWS_EFS_FILE_JSON | jq '.FileSystems['"$loopcount"'].CreationToken'`
		efssize=`cat $AWS_EFS_FILE_JSON | jq '.FileSystems['"$loopcount"'].SizeInBytes.Value'`; efssize=`echo "scale=4; $efssize / 8 / 1024 / 1024" | bc`
		echo "EFS # $loopcount -- ID: $efsid -- Create Date: $efscreatetime -- State: $efsstate -- Encryption: $efsencryption -- Type: $efsperformancemode -- OwnerID: $efsownerid -- Targets: $efstargets -- Token: $efscreationtoken -- Size: $efssize GB" >> $AWS_EFS_FILE_PRETTY
		let loopcount=loopcount+1
	done
	sed -i -e 's/"//g' $AWS_EFS_FILE_PRETTY
	while read line; do agentSendLogMessage "$line"; done < $AWS_EFS_FILE_PRETTY
}

# Main
agentSendLogMessage "#### EFS FILE SYSTEM DELETE SERVICE STARTING ####"

installPrerequisites
installAWSCli
configureAWSCli
listAWSEfs
deleteAWSEfs
listAWSEfs

agentSendLogMessage "#### EFS FILE SYSTEM DELETE SERVICE COMPLETE ####"

exit 0