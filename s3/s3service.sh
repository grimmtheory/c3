#!/bin/bash
#title           :service.sh
#description     : Service cript for AWS S3 Service .
#author		 :demehta
#date            :2018-01-16
#version         :0.1
#usage		 :bash service.sh $cmd

# DMM TODO's

#For external-service
. /utils.sh
print_log "$(env)"

cmd=$1
function=$function
bucketName=$bucketName
export SVCNAME=s3service
export INSTALL_DIR="/usr/local/aws"

print_log "Service Name :: $SVCNAME"

# print and verify if access and secret key are defined as app or service parameters. 
#print_log "AWS Access Key :: $AWS_ACCESS_KEY"
#print_log "AWS Secret Key :: $AWS_SECRET_KEY"

echo "CLIQR_EXTERNAL_SERVICE_LOG_MSG_START"
echo "Executing Installing AWS CLI"
echo "CLIQR_EXTERNAL_SERVICE_LOG_MSG_END"

# For Testing
#if [ -z $AWS_SECRET_KEY ]
#then
#    print_log "AWS_SECRET_KEY not specified"
#    exit
#fi

installAWSCli() {
    print_log "Installing AWS CLI tools..."
        if [ -d $INSTALL_DIR ]; then
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
    print_log "Configuring AWS CLI..."
        export JAVA_HOME="/usr/lib/jvm/jre"
        export EC2_REGION="$region"
        export PATH=$PATH:$INSTALL_DIR/bin
        if [ -z "$EC2_REGION" ]
	then
	    export EC2_REGION="us-west-2"
	    export region="us-west-2"
        fi

        if [ ! -z "$CliqrCloud_EC2ARN" ];
        then
                credresult=`aws sts assume-role --role-arn "$CliqrCloud_EC2ARN" --role-session-name "MyRoleSessionName"`
                if [ ! -n $credresult ];
                then
                        print_error "Error in generating credentials using the role : $CliqrCloud_EC2ARN";
                        exit 127
                fi
                export AWS_SECRET_ACCESS_KEY=`echo $credresult | awk -F SecretAccessKey '{printf $2}' | awk -F \" '{printf $3}'`
                export AWS_ACCESS_KEY_ID=`echo $credresult | awk -F AccessKeyId '{printf $2}' | awk -F \" '{printf $3}'`
                export AWS_SECURITY_TOKEN=`echo $credresult | awk -F SessionToken '{printf $2}' | awk -F \" '{printf $3}'`
        elif [ -z $CliqrCloudAccountPwd ] || [ -z $CliqrCloud_AccessSecretKey ];
        then
                print_error "Insufficient permissions to access the Cloud Account, contact your Admin for the Cloud Account Accessibility";
                exit 127
        else
                export AWS_ACCESS_KEY_ID="$CliqrCloudAccountPwd"
                export AWS_SECRET_ACCESS_KEY="$CliqrCloud_AccessSecretKey"

        fi

        if [ -z $AWS_ACCESS_KEY_ID ];then
                        print_error "Cloud Account Access Key not found or couldn't generate with IAM role"
                        exit 127
        fi

        if [ -z $AWS_SECRET_ACCESS_KEY ];then
                        print_error "Cloud Account Secret Key not found or couldn't generate with IAM role"
                        exit 127
        fi

        if [ -z $region ];then
                        print_error "Region Value is not set"
                        exit 127
        fi

        export "AWS_DEFAULT_REGION"=$region
        print_log "AWS Access Key :: $AWS_ACCESS_KEY_ID"
        #print_log "AWS Secret Key :: $AWS_SECRET_ACCESS_KEY"
        print_log "AWS Region :: $AWS_DEFAULT_REGION"

}

print_log "Executing service script --  $cmd "
echo "Executing service script --  $cmd "

case $cmd in
	install)
		;;
	configure)
		;;
	deploy)
		;;
	start)
		print_log "Install and configuring AWS CLI"
		installAWSCli
		configureAWSCli
                returnList=`aws s3 ls`
                print_log $returnList 
                case $function in
			cp)
				print_log "Performing copy operation. Validating Inputs."
				if [ -z $source ] || [ -z $target ]
				then
				    print_log "Either source or target not specified. Abort operation"
				    exit
				fi
				if [[ $target != s3://** ]]
				then	
				    print_log "Target Needs to be an S3 location"
				else
				    wget $source
				    sourceFileName=$(basename $source)
				    print_log "Copying $sourceFileName to $target"
				    aws s3 cp $sourceFileName $target
				    print_log "Finished copying $sourceFileName to $target"
			        fi	
				;;
			ls)
                                print_log "Listing All AWS Buckets"
                                bucketList=`aws s3 ls`
				print_log $bucketList
				;;
			mb)
				print_log "Making a new bucket"
				aws s3 mb s3://$bucketName
				print_log "Bucket $bucketName created successfully"
				;;
			mv)
				;;
			presign)
				;;
			rb)
				print_log "Removing bucket :: $bucketName"
				aws s3 rb s3://$bucketName
				print_log "Bucket $bucketName removed successfully"
				;;
			rm)
				print_log "Removing s3 object :: $target"
				if [[ $target != s3://** ]]
                                then
                                    print_log "Target Needs to be an S3 location"
                                else
                                    aws s3 rm $target
                                    print_log "Object $target removed successfully"
				fi
				;;
			sync)
				;;
			website)	
				;;
		esac
		;;
	stop)
		installAWSCli
		configureAWSCli
		;;
	restart)
		;;
	reload)
		;;
	upgrade)
		;;
	cleanup)
		;;
	*)
		;;
esac
