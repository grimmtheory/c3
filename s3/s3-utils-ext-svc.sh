#!/bin/bash
# Title		: s3-utils-ext-svc.sh
# Description	: An external utility service for AWS s3 functions, e.g. list, create, and delete buckets.
# Author	: jasgrimm
# Date		: 2018-04-03
# Version	: 0.1
# Usage		: bash s3-utils-ext-svc.sh $cmd (defaults to start), FUNCTION=$function < pulled in from service paramater passed
# External Vars	: Read in at run time - $BUCKET_NAME, $FUNCTION which is a pick list of "LB", "CB", "DB" for list, create, or delete
#				  aws_access_key_id and aws_secret_access_key
# Internal Vars	: Initialized within srcipt - $AWS_INSTALL_DIR, $AWS_CONFIG_DIR, $AWS_CONFIG_FILE, $AWS_CRED_FILE

# If running as an "external-service" (default)
. /utils.sh

# If running within a virtual machine (default)
# . /usr/local/osmosix/etc/.osmosix.sh
# . /usr/local/osmosix/etc/userenv
# . /usr/local/osmosix/service/utils/cfgutil.sh
# . /usr/local/osmosix/service/utils/agent_util.sh

# debug
print_log "$(env)"

# Declare / configure internal vars
CMD=$1
FUNCTION=$function
AWS_INSTALL_DIR="/usr/local/aws"
PATH=$PATH:$AWS_INSTALL_DIR/bin
AWS_ACCESS_KEY_ID=$aws_access_key_id
AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
AWS_CONFIG_DIR="/root/.aws"
AWS_CONFIG_FILE="$AWS_CONFIG_DIR/config"
AWS_CRED_FILE="$AWS_CONFIG_DIR/credentials"
AWS_BUCKET_FILE_JSON="/root/bucketlist.json.txt"
AWS_BUCKET_FILE_PRETTY="/root/bucketlist.pretty.txt"

# Install prerequisites
installPrerequisites() {
	print_log "Installing prerequisites..."
	if [ -f /bin/jq ]; then
		print_log "JQ is already installed, skipping install."
	else
		print_log "JQ is not installed, installing now."
		yum -y --skip-broken install jq
	fi
}

# Functions
installAWSCli() {
    print_log "Installing AWS CLI tools..."

        if [ -f $AWS_INSTALL_DIR/bin/aws ]; then
            print_log  "AWS CLI already installed, skipping the AWS CLI Install."
        else
            mkdir -p $AWS_INSTALL_DIR; cd $AWS_INSTALL_DIR
            wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip; unzip awscli-bundle.zip
            ./awscli-bundle/install -i $AWS_INSTALL_DIR
            print_log  "AWS CLI tools are now installed."
        fi
}

configureAWSCli() {
	print_log "Configuring AWS CLI tools..."

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
	print_log "Listing AWS S3 Buckets with command: $AWS_INSTALL_DIR/bin/aws s3api list-buckets"

	$AWS_INSTALL_DIR/bin/aws s3api list-buckets > $AWS_BUCKET_FILE_JSON
	print_log "JSON Format"
	print_log `cat $AWS_BUCKET_FILE_JSON`

	print_log "List Format"
	echo "" > $AWS_BUCKET_FILE_PRETTY
	loopcount=0
	bucketcount=`cat $AWS_BUCKET_FILE_JSON | grep Creation | wc -l`
	while [ $loopcount -lt $bucketcount ]; do
		bucketname=`cat $AWS_BUCKET_FILE_JSON | jq '.Buckets['"$loopcount"'].Name' | sed -e 's/"//g'`
		bucketcreatedate=`cat $AWS_BUCKET_FILE_JSON | jq '.Buckets['"$loopcount"'].CreationDate' | awk -F\T '{ print $1 }' | sed -e 's/"//g'`
		bucketcreatetime=`cat $AWS_BUCKET_FILE_JSON | jq '.Buckets['"$loopcount"'].CreationDate' | awk -F\T '{ print $2 }' | awk -F. '{ print $1 }'`
		echo "Bucket # $loopcount  ---  Name: $bucketname  ---  Create Date: $bucketcreatedate  ---  Create Time: $bucketcreatetime" >> $AWS_BUCKET_FILE_PRETTY
		let loopcount=loopcount+1
	done
	while read line; do print_log "$line"; done < $AWS_BUCKET_FILE_PRETTY
}

# Main
print_log "#### S3 UTILITY SERVICE STARTING ####"

## Install Prerequisites, AWSCli, and configure
installPrerequisites
installAWSCli
configureAWSCli

## Cases
case $CMD in
	start)
		case $FUNCTION in
			LB)
				istAWSBuckets
				;;
			CB)
				;;
			DB)
				;;
			*)
				;;
		esac
		;;
	*)
		;;
esac

print_log "#### S3 UTILITY SERVICE COMPLETE ####"

exit 0