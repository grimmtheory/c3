#!/bin/bash
# Title		: s3list.sh
# Description	: Lifecycle action script for listing AWS S3 buckets.
# Author	: jasgrimm
# Date		: 2018-04-01
# Version	: 0.1
# Usage		: bash s3list.sh
# External Vars	: Read in at run time - $AWS_REGION, $AWS_ACCESS_KEY_ID, and $AWS_SECRET_ACCESS_KEY
# Internal Vars	: Initialized within srcipt - $AWS_INSTALL_DIR, $AWS_CONFIG_DIR, $AWS_CONFIG_FILE, $AWS_CRED_FILE

# If running as an "external-service", execute and terminate docker container on the orchestrator
. /utils.sh
print_log "$(env)"

# If running within a virtual machine (default)
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

# Declare / configure internal vars
AWS_INSTALL_DIR="/usr/local/aws"
PATH=$PATH:$INSTALL_DIR/bin
AWS_CONFIG_DIR="/root/.aws"
AWS_CONFIG_FILE="$AWS_HOME/config"
AWS_CRED_FILE="$AWS_HOME/credentials"

# Functions
installAWSCli() {
    agentSendLogMessage "Installing AWS CLI tools..."

        if [ -d $AWS_INSTALL_DIR ]; then
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

listAWSBuckets() {
	agentSendLogMessage "Listing AWS S3 Buckets with command: $AWS_INSTALL_DIR/bin/aws s3api list-buckets"
	returnList=`$AWS_INSTALL_DIR/bin/aws s3api list-buckets`
	agentSendLogMessage $returnList
}

# Main
agentSendLogMessage "** S3 Bucket List Service Starting **"

installAWSCli
configureAWSCli
listAWSBuckets

agentSendLogMessage "** S3 Bucket List Service Complete **"

exit 0