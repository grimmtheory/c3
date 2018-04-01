#!/bin/bash
# Source Vars - $AWS_REGION, $AWS_ACCESS_KEY_ID, and $AWS_SECRET_ACCESS_KEY and
# $AWS_BUCKET_NAME is passed in from CloudCenter via a visible +/- editble or hidden paramater
. /usr/local/osmosix/etc/.osmosix.sh; . /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh; . /usr/local/osmosix/service/utils/agent_util.sh
INSTALL_DIR="/usr/local/aws"
export PATH=$PATH:$INSTALL_DIR/bin
AWS_HOME="/root/.aws"
AWS_CONFIG="$AWS_HOME/config"
AWS_CREDS="$AWS_HOME/credentials"

agentSendLogMessage "** S3 Bucket Creation Service Starting **"

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
	mkdir -p $AWS_HOME
	echo "[default]" > $AWS_CONFIG
	echo "region = $AWS_REGION" >> $AWS_CONFIG
	chmod 600 $AWS_CONFIG
	echo "[default]" > $AWS_CREDS
	echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> $AWS_CREDS
	echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> $AWS_CREDS
	chmod 600 $AWS_CREDS
}

createAWSBucket() {
	agentSendLogMessage "Creating AWS S3 Bucket..."
	returnList=`$INSTALL_DIR/bin/aws s3api create-bucket --bucket $AWS_BUCKET_NAME \
	--region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION`
	agentSendLogMessage $returnList
}

listAWSBuckets() {
	agentSendLogMessage "Listing AWS S3 Buckets..."
	returnList=`$INSTALL_DIR/bin/aws s3api list-buckets`
	agentSendLogMessage $returnList
}

installAWSCli
configureAWSCli
createAWSBucket
listAWSBuckets

agentSendLogMessage "** S3 Bucket Creation Service Complete **"

exit 0