#!/bin/bash
#
# RAP
#
# This service uses email to enable submitted jobs to go through an approval process.
# 
# The primary use case for this service is for environments where more complex approval processes
# are desired, e.g. beyond the native single step approval process at the deployment environment 
# level, and no other external mechanism is available to handle these requests, e.g. an ESC or CMDB.
#
# RAP env vars to be used or mapped into Cloud Center
#
#		$ArchEmail - Email address of the approving architect.
#		$ArchApprovalAmount - The highest dollar amount that an architect can approve.
#		$MgrEmail - Email address of the approving architect.
#		$MgrApprovalAmount - The highest dollar amount that a manager can approve.
#		$DirEmail - Email address of the approving architect.
#		$DirApprovalAmount - The highest dollar amount that a director can approve.
#		$VPEmail - Email address of the approving architect.
#		$VPApprovalAmount - The highest dollar amount that a VP can approve.
#
#		$RAPEmail - Email address that the RAP service will use.
#		$RAPLogin - The username that the RAP service will use to login to email.
#		$RAPPass - The password that the RAP service will use to login to email.
#		$Pop3Server - The IP address or DNS name of the Pop3 server used to receive email.
#		$SMTPServer - The IP address or DNS name of the SMTP server used to send email.
# 
#		cmd for our case statement is the first parameter passed in is either start or stop
# 		to run: service <start> or <stop> 
#

# Source variables
print_log "Sourcing variables"
source /usr/local/osmosix/etc/.osmosix.sh
source /usr/local/osmosix/etc/userenv
source /usr/local/osmosix/service/utils/cfgutil.sh
source /usr/local/osmosix/service/utils/agent_util.sh

# Output env locally and to the log (for debug)
print_log "$(env)"
env

# Set cmd to $1 for the start, stop, resume, etc. cases
cmd=$1

# Run everything as root
if [ "$(id -u)" != "0" ]; then
    exec sudo "$0" "$@"
fi

# Setup prereqs
print_log "Installing Prereqs"
yum -y --skip-broken update
yum -y --skip-broken install mutt fetchmail postfix openssl cyrus-sasl cyrus-sasl-plain \
cyrus-sasl-md5 cyrus-sasl-devel cyrus-sasl-gssapi mailx
print_log "Prereqs install complete"

# Functions
## Execution status
function executionStatus() {
 FILE="status.txt"
 status=`cat $FILE`
 print_log "$status"

if grep -q "Error" "$FILE"; then
   exit 1
fi

}

## Setup Mutt
function muttSetup() {
 touch $MAIL
 chmod 660 $MAIL
 chown `whoami`:mail $MAIL
 mkdir -p ~/.mutt/cache
 touch ~/.mutt/cache/headers
 touch ~/.mutt/cache/bodies
 touch ~/.mutt/certificates
cat <<EOF > ~/.muttrc
set from = "prgrimm04@gmail.com"
set realname = "Parker Grimm"
set smtp_url = "smtp://prgrimm04@smtp.gmail.com:587/"
set smtp_pass = $RAPPass
set imap_user = "prgrimm04@gmail.com"
set imap_pass = $RAPass
set folder = "imaps://imap.gmail.com:993"
set spoolfile = "+INBOX"
set timeout = 300
set imap_keepalive = 300
set postponed = "+[GMail]/Drafts"
set record = "+[GMail]/Sent Mail"
set header_cache=~/.mutt/cache/headers
set message_cachedir=~/.mutt/cache/bodies
set certificate_file=~/.mutt/certificates
set move = no
EOF
}

# Cases
case $cmd in
	start)
		print_log "Executing Service.."
		echo "Everything is OK" | mutt -s "TEST email - mutt SMTP" jgrimm73@gmail.com
		executionStatus
		;;
	stop)
		print_log "Deleting Service.."
		executionStatus
		;;
	update)
		print_log "Updating Service.."
		;;
	*)
		serviceStatus="No Valid Script Argument"
		exit 127
		;;
esac







