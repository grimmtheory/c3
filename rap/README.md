# RAP - Request Approval Process

This service uses email to enable submitted jobs to go through an approval process.

The primary use case for this service is for environments where more complex approval processes are desired, e.g. beyond the native single step approval process at the deployment environment level, and no other external mechanism is available to handle these requests, e.g. an ESC or CMDB.

Typically this service would be placed at the lowest level of the application profile, such that an approved request (exit 0) allows the job to continue on processing, and a denied request (exit 1) causes the job to terminate.  However, the service should work fine if placed between components as well.

By default the service comes with 4 approval levels - architect, manager, director, and VP; the process utilizes TotalCost as the mechanism to decide the number of approvals required.  TotalCost, by default, is calculated by multiplying the MonthlyCost x 36.

The service can be modified as needed, the default configuration options are available in the service properties section of the web-ui and are as follows:

1. ArchEmail, ArchApprovalAmount
2. MgrEmail, MgrApprovalAmount
3. DirEmail, DirApprovalAmount
4. VPName, VPEmail, VPApprovalAmount
5. RAPEmail, RAPUser, RAPLogin, RAPPass
6. Pop3Server, IMAPServer, SMTPServer

The service uses several native CloudCenter environment variables, e.g.:

1. AppName (from cliqrAppName)
2. RequestUserName (from launchUserName)
3. DepEnv (from CliqrDepEnvName)

The flow of the service can be seen here https://github.com/grimmtheory/c3/blob/master/rap/tmp/approval-flow.jpg, but the basic process is as follows:

1. Create Variables
2. Install Prerequisites, configure tools, e.g. mutt, fetchmail, etc.
3. Check if approval is required, if not exit 0, if so then
* Create an email template, e.g. RequestUserName is requesting application AppName be deployed to DepEnv %Today% at %TIME%, please reply with approved or denied.
* Send email request to ArchEmail
* Poll the POP3 server every 60 seconds for messages with matching %JOB_NAME% and pull new messages
* If the message contains approved, check to see if further approvals are needed, and if so send another email to the next approver, else exit the service with an error (terminating the job)
* Log the events and email the requesting user %EMAIL_ADDRESS% with the status

This service is written in python using native smtplib and poplib modules.  More info and references can be found here https://docs.python.org/3/library/smtplib.html and here https://docs.python.org/3/library/poplib.html

This has been tested with CloudCenter 4.8.2.1

This service is released under the GNU General Public License version 2.0, which is an open source license.

![approval flow](https://raw.githubusercontent.com/grimmtheory/c3/master/rap/tmp/approval-flow.jpg)
