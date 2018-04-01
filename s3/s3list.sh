#!/bin/bash
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

export SVCNAME="s3list"
export INSTALL_DIR="/usr/local/aws"
export EC2_REGION="$region"

agentSendLogMessage "Service Name :: $SVCNAME starting"

# print and verify if access and secret key are defined as app or service parameters.
agentSendLogMessage "AWS Region :: $EC2_REGION"
agentSendLogMessage "AWS Secret Key :: $AWS_SECRET_KEY"
agentSendLogMessage "AWS Access Key :: $AWS_ACCESS_KEY"

# For Testing
if [ -z $AWS_SECRET_KEY ]; then
    agentSendLogMessage "AWS_SECRET_KEY not specified"
    exit 1
fi

installAWSCli() {
    agentSendLogMessage "Installing AWS CLI tools..."
        if [ type aws > /dev/null ]; then
            echo  "AWS Cli already installed skipping the AWS Cli Install";
            export PATH=$PATH:$INSTALL_DIR/bin
            echo "PATH value is = $PATH"
        else
            mkdir -p $INSTALL_DIR
            cd $INSTALL_DIR
            wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
            unzip awscli-bundle.zip
            ./awscli-bundle/install -i $INSTALL_DIR
            rm -f awscli-bundle.zip
            export PATH=$PATH:$INSTALL_DIR/bin
            echo "PATH value is = $PATH"
        fi
}

configureAWSCli() {
    agentSendLogMessage "Configuring AWS CLI..."
        export JAVA_HOME="/usr/lib/jvm/jre"
        export PATH=$PATH:$INSTALL_DIR/bin

        if [ -z "$EC2_REGION" ]; then
	    	export EC2_REGION="us-west-2"
	    	export region="us-west-2"
        fi

        if [ ! -z "$CliqrCloud_EC2ARN" ]; then
            credresult=`aws sts assume-role --role-arn "$CliqrCloud_EC2ARN" --role-session-name "MyRoleSessionName"`
            if [ ! -n $credresult ]; then
                agentSendLogMessage "Error in generating credentials using the role : $CliqrCloud_EC2ARN";
                exit 1
            fi

        export AWS_SECRET_ACCESS_KEY=`echo $credresult | awk -F SecretAccessKey '{printf $2}' | awk -F \" '{printf $3}'`
        export AWS_ACCESS_KEY_ID=`echo $credresult | awk -F AccessKeyId '{printf $2}' | awk -F \" '{printf $3}'`
        export AWS_SECURITY_TOKEN=`echo $credresult | awk -F SessionToken '{printf $2}' | awk -F \" '{printf $3}'`

        elif [ -z $CliqrCloudAccountPwd ] || [ -z $CliqrCloud_AccessSecretKey ]; then
            agentSendLogMessage "Insufficient permissions to access the Cloud Account, contact your Admin for the Cloud Account Accessibility";
            exit 1
        else
            export AWS_ACCESS_KEY_ID="$CliqrCloudAccountPwd"
            export AWS_SECRET_ACCESS_KEY="$CliqrCloud_AccessSecretKey"
        fi

        if [ -z $AWS_ACCESS_KEY_ID ]; then
            agentSendLogMessage "Cloud Account Access Key not found or couldn't generate with IAM role"
            exit 1
        fi

        if [ -z $AWS_SECRET_ACCESS_KEY ]; then
            agentSendLogMessage "Cloud Account Secret Key not found or couldn't generate with IAM role"
            exit 1
        fi

        if [ -z $region ]; then
            agentSendLogMessage "Region Value is not set"
            exit 1
        fi

        export "AWS_DEFAULT_REGION"=$region
        agentSendLogMessage "AWS Access Key :: $AWS_ACCESS_KEY_ID"
        agentSendLogMessage "AWS Secret Key :: $AWS_SECRET_ACCESS_KEY"
        agentSendLogMessage "AWS Region :: $AWS_DEFAULT_REGION"
}

agentSendLogMessage "Executing service script"
agentSendLogMessage "Install and configuring AWS CLI"

installAWSCli
configureAWSCli
returnList=`aws s3 ls`
agentSendLogMessage $returnList