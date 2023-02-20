#! /bin/bash

# run runEc2.sh vpcId(target) source_profile target_profile

for ami in $(cat amiId.txt)
do

myami=$(echo $ami | xargs)
echo $myami

aws ec2 describe-images --image-ids $myami --query Images[*].Tags[*] --output json --profile $2 > ami.json
let length=$( jq '.[0] | length' ami.json)

echo $length

for((i=0;i<$length;i++));
do
    Key=$(jq -r ".[0][$i].Key" ami.json | xargs)
    
    if [ "$Key" == "Ec2" ]
    then
      NewName=$(jq -r ".[0][$i].Value" ami.json | xargs)
    elif [ "$Key" == "Az" ] 
    then
       Az=$(jq -r ".[0][$i].Value" ami.json | xargs)
    elif [ "$Key" == "Sg" ] 
    then
      SgId=$(jq -r ".[0][$i].Value" ami.json | xargs)
    elif [ "$Key" == "Type" ] 
    then
      InstanceType=$(jq -r ".[0][$i].Value" ami.json | xargs)
    fi
        
done

Namearr=(${NewName// / })
sg_Name="Security-Group-us-east-1-Test-${Namearr[0]}"


sg_id=$(./sg.sh "$1" "$SgId" "$2" "$3" "$sg_Name")
aws ec2 authorize-security-group-ingress --group-id $sg_id --ip-permissions file://sg.json --profile $3
echo "$sg_id in run_EC2"

./BlockDevice.sh "$myami" "$2" "arn:aws:kms:us-east-1:959157593968:key/8ee25090-ae63-4a6b-b9f9-ec00df72e6a2"

AMI_ID="$myami"
INSTANCE_TYPE="$InstanceType"
KEY_PAIR_NAME="KeyName"
if [ "$Az" == "us-east-1a" ]
then
 SUBNET_NAME="subnet-xxxxx"
elif [ "$Az" == "us-east-1b" ] 
then
 SUBNET_NAME="subnet-xxxyyy"
fi    
IAM="roleName"

INSTANCE_ID=$(aws ec2 run-instances --image-id "$AMI_ID" --count 1 --instance-type "$INSTANCE_TYPE" --key-name "$KEY_PAIR_NAME" --security-group-ids "$sg_id" --subnet-id "$SUBNET_NAME" --block-device-mappings file://BlockDeviceMappings.json --iam-instance-profile {\"Name\":\"$IAM\"} --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=\"$NewName\"},{Key=Env,Value=Prod}]" --output text --query 'Instances[0].InstanceId' --profile $3)

(echo "$INSTANCE_ID" | xargs )>> InstanceId.txt

done

