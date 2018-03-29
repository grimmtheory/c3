import sys, os, requests, json, sys, poplib, smtplib, email

##Functions##
def sendEmail(SMTPServer, RAPEmail, RAPLogin, RAPPass)
    

##Variables##
ArchEmail = os.getenv('ArchEmail')
ArchApprovalAmount = os.getenv('ArchApprovalAmount')
MgrEmail = os.getenv('MgrEmail')
MgrApprovalAmount = os.getenv('MgrApprovalAmount')
DirEmail = os.getenv('DirEmail')
DirApprovalAmount = os.getenv('DirApprovalAmount')
VPEmail = os.getenv('VPEmail')

RAPEmail = os.getenv('RAPEmail')
RAPLogin = os.getenv('RAPLogin')
RAPPass = os.getenv('RAPPass')

Pop3Server = os.getenv('Pop3Server')
SMTPServer = os.getenv('SMTPServer')

AppName = os.getenv('cliqrAppName')
RequestUserName = os.getenv('launchUserName')
DepEnv = os.getenv('CliqrDepEnvName')

TotalCost = 500 #Placeholder for testing, needing to find cost Var and calculate

##Main begins here##
if TotalCost <= ArchApprovalAmount:
    print("No approvals required, exiting.")
    sys.exit(0)