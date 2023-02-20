#! /bin/bash

# author:- shreyansh nowlkha
# need ami , source_account_profile , kmsKeyArn
# ./BlockDevice.sh ami account_profile kmskey

aws ec2 describe-images --region us-east-1 --image-ids $1 --query "Images[0].BlockDeviceMappings[*]" --profile $2 > mynewmap.json

jq ".[].Ebs +={\"KmsKeyId\": \"$3\"}" mynewmap.json > BlockDeviceMappings.json

