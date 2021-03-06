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
#		$RAPUser - RAP user short name.
#		$RAPLogin - The username that the RAP service will use to login to email.
#		$RAPPass - The password that the RAP service will use to login to email.
#		$Pop3Server - The IP address or DNS name of the Pop3 server used to receive email.
#		$IMAPServer - The IP address or DNS name of the IMAP server used to receive email.
#		$SMTPServer - The IP address or DNS name of the SMTP server used to send email.
# 
#		cmd for our case statement is the first parameter passed in is either start or stop
# 		to run: service <start> or <stop> 
#

# Source variables
function sourceVars() {
 print_log "Sourcing variables"
 source /utils.sh
 source /usr/local/osmosix/etc/.osmosix.sh
 source /usr/local/osmosix/etc/userenv
 source /usr/local/osmosix/service/utils/cfgutil.sh
 source /usr/local/osmosix/service/utils/agent_util.sh
 print_log "$(env)"
}

# Set cmd to $1 for the start, stop, resume, etc. cases
cmd=$1

# Run everything as root
if [ "$(id -u)" != "0" ]; then
    exec sudo "$0" "$@"
fi

# Functions
## Execution status
function executionStatus() {
 StatusFile="~/status.txt"
 echo "" > $StatusFile
 status=`cat $StatusFile`
 print_log "$status"
# if grep -q "Error" "$StatusFile"; then
#    exit 1
# fi
}

## Setup prereqs
function setupPrereqs() {
 print_log "Installing Prereqs"
 yum -y --skip-broken update
 yum -y --skip-broken install mutt fetchmail mailcap procmail postfix openssl openssl-devel wget ncurses-devel perl vim cyrus-sasl cyrus-sasl-plain \
 cyrus-sasl-md5 cyrus-sasl-devel cyrus-sasl-gssapi mailx
 print_log "Prereqs install complete"
}

## Setup Mutt
function setupMutt() {
 print_log "Setting up Mutt"
 touch $MAIL
 chmod 660 $MAIL
 chown `whoami`:mail $MAIL
 mkdir -p ~/.mutt/cache
 touch ~/.mutt/cache/headers
 touch ~/.mutt/cache/bodies
 touch ~/.mutt/certificates
 echo "" > ~/.muttrc

cat <<EOF > ~/.muttrc
set from = "$RAPLogin"
set realname = "$RAPUser"
set smtp_url = "smtp://$RAPUser@$SMTPServer:587/"
set smtp_pass = "$RAPPass"
set imap_user = "$RAPLogin"
set imap_pass = "$RAPPass"
set folder = "imaps://$IMAPServer:993"
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

 chmod 600 ~/.muttrc
 print_log "$(cat ~/.muttrc)"
 print_log "Mutt setup complete"
}

## Setup Fetchmail
function setupFetchmail() {
 print_log "Setting up Fetchmail"
 mkdir ~/.fetchmail

cat <<EOF > ~/.fetchmailrc
# set username
set postmaster `whoami`
# set polling time (5 minutes)
# set daemon 600
poll $Pop3Server with proto POP3
   user $RAPLogin there with password $RAPPass is `whoami` here options ssl
EOF

 chmod 600 ~/.fetchmailrc
 print_log "$(cat ~/.fetchmailrc)"
 print_log "Fetchmail setup complete"
}

## Test SMTP
function testSMTP() {
 print_log "Testing SMTP"
  print_log "$(echo \"Everything is OK\" \| mutt -s \"TEST email - mutt SMTP\" $ArchEmail)"
 # echo "Everything is OK" | mutt -s "TEST email - mutt SMTP" $ArchEmail
 echo "$RAPUser has requested to launch a VM, please reply to this email with approve or deny" > ~/message.txt
 mutt -s "$RAPUser has requested to launch a VM" $ArchEmail < ~/message.txt
 print_log "SMTP testing complete"
}

## Debug
function doDebug() {
 print_log "Start Debugging"
 DebugFile=~/debug.txt

 print_log "Debug - Installing nmap"
 echo "Install nmap" >> $DebugFile
 yum -y --skip-broken install nmap >> $DebugFile

 print_log "Debug - Checking ports"
 echo "Network check" >> $DebugFile
 nmap -P0 -p 25 $SMTPServer >> $DebugFile
 nmap -P0 -p 995 $Pop3Server >> $DebugFile

 print_log "Debug - Checking mutt config"
 echo "Debug - Checking mutt" >> $DebugFile
 cat ~/.muttrc >> $DebugFile
 mutt -v >> $DebugFile

 print_log "Debug - Testing SMTP"
 testSMTP >> $DebugFile

 print_log "Debug - Checking fetchmail"
 echo "Fetchmail check" >> $DebugFile
 cat ~/.fetchmailrc >> $DebugFile
 fetchmail >> $DebugFile
 mail -H >> $DebugFile

 print_log "$(cat ~/debug.txt)"
}

# Cases
case $cmd in
	start)
		print_log "Executing Service.."
		sourceVars
		setupPrereqs
		setupMutt
		setupFetchmail
		doDebug
		testSMTP
		executionStatus
		;;
	stop)
		print_log "Stopping Service.."
		executionStatus
		;;
	suspend)
		print_log "Suspending Service.."
		executionStatus
		;;
	resume)
		print_log "Resuming Service.."
		executionStatus
		;;
	update)
		print_log "Updating Service.."
		executionStatus
		;;
	*)
		serviceStatus="No Valid Script Argument"
		exit 127
		;;
esac