#!/bin/bash
# Source Vars - $AWS_REGION, $AWS_ACCESS_KEY_ID, and $AWS_SECRET_ACCESS_KEY is passed in from
# CloudCenter via a visible +/- editble or hidden paramater
. /usr/local/osmosix/etc/.osmosix.sh; . /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh; . /usr/local/osmosix/service/utils/agent_util.sh
INSTALL_DIR="/usr/local/aws"
export PATH=$PATH:$INSTALL_DIR/bin

agentSendLogMessage "Service Name :: s3 Bucket List starting"

installAWSCli() {
    agentSendLogMessage "Installing AWS CLI tools..."
        if [ type aws > /dev/null ]; then
            agentSendLogMessage  "AWS CLI already installed skipping the AWS CLI Install";
        else
            mkdir -p $INSTALL_DIR; cd $INSTALL_DIR
            wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip; unzip awscli-bundle.zip
            ./awscli-bundle/install -i $INSTALL_DIR
        fi
}

configureAWSCli() {
	agentSendLogMessage "Configuring AWS CLI tools..."
	echo "[default]" > ~/.aws/config
	echo "region = $AWS_REGION" >> ~/.aws/config
	echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" > ~/.aws/credentials
	echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> ~/.aws/credentials
}

listAWSBuckets() {
	agentSendLogMessage "Listing AWS S3 Buckets..."
	returnList=`aws s3api list-buckets`
	agentSendLogMessage $returnList
}

installAWSCli
configureAWSCli
listAWSBuckets

exit 0