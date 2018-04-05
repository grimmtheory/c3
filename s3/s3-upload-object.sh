#!/bin/bash
# s3 object upload

# Inherited 
# $AWS_ACCESS_KEY_ID
# $AWS_SECRET_ACCESS_KEY
# $AWS_REGION
# $AWS_BUCKET_NAME
# $FILE
# $FUNCTION

date=`date +%Y%m%d`

s3put() {
    resource="/${$AWS_BUCKET_NAME}/${$FILE}"
    contentType="text/plain"
    dateValue=`date -R`
    stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"

    signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${$AWS_SECRET_ACCESS_KEY} -binary | base64`
    curl -X PUT -T "${$FILE}" \
        -H "Host: ${$AWS_BUCKET_NAME}.s3.amazonaws.com" \
        -H "Date: ${dateValue}" \
        -H "Content-Type: ${contentType}" \
        -H "Authorization: AWS ${$AWS_ACCESS_KEY_ID}:${signature}" \
        https://${$AWS_BUCKET_NAME}.s3.amazonaws.com/${$FILE}
}
