## AWS S3 tools and services for Cisco CloudCenter

1. s3service.sh - original service from Deepak Mehta (thank you)
2. s3-upload-object.sh - object uplaod testing with curl / api only without using the aws cli
3. s3-uitls-ext-svc.sh - External service for bucket list, create, and delete.  Written to run in a container. Works pretty well, but is still aws cli based.   
4. s3create.sh - lifecycle action / single function, creates an s3 bucket; meant to run in an already deployed VM as a day 2 action.
5. s3delete.sh - lifecycle action / single function, deletes an s3 bucket; meant to run in an already deployed VM as a day 2 action.
6. s3list.sh - lifecycle action / single function, lists s3 buckets; meant to run in an already deployed VM as a day 2 action.