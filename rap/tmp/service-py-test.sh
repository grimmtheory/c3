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
# Cloud Foundry env vars to be used or mapped into Cloud Center
#
#		$CF_API - API endpoint of cloud foundry instance  
#		$CF_USER - User name in cloud foundry
#		$CF_PASS - Password
#		$CF_ORG - Org
#		$CF_SPACE - Space
#		$CF_APP_URL - URL to HTTP location to grab application
#		$CF_APP_NAME - App name in CF that we are creating 
#		$APP_DIR - Name of the directory the applications is in
# 		$APP_BUILD_TYPE - type of application to compile, mavin, gradle, python, static
#		(today we only have gradle in this example, enhancement to expand it to the UI)
# 
#		cmd for our case statement is the first parameter passed in is either start or stop
# 		to run: service <start> or <stop> 
#
