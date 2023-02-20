#! /bin/bash


# ./amiChangePermissions.sh account_id profile
for ami in $(cat amiId.txt)
do

 myami=$(echo $ami | xargs)
 echo "Changing Permission:- $myami"
 aws ec2 modify-image-attribute --image-id $myami --launch-permission "{\"Add\": [{\"UserId\": \"$1\"}]}" --profile $2
done