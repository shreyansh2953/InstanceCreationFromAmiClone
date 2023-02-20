#! /bin/bash

# Author:- shreyansh
#need Source sg , source profile
#need target sg name to be created, target profile ,target VPC
# returns groupID

# ./sg.sh $vpcid $source_sg $souce_profile_name $target_profile_name $sg_name

str="{\"FromPort\":fpt,\"IpProtocol\":\"Ippt\",\"IpRanges\":[{\"CidrIp\":\"10.0.0.0/8\"}],\"ToPort\":mytpt}"

declare -a myarr
myarr=()
let i=0
for sgFromport in $(aws ec2 describe-security-groups --group-ids $2 --query "SecurityGroups[0].IpPermissions[*].FromPort" --output text --profile $3)
do
  # echo $sgFromport
  myarr+=(${str/fpt/"$sgFromport"})
  let i++
done

let i=0
for sgToport in $(aws ec2 describe-security-groups --group-ids $2 --query "SecurityGroups[0].IpPermissions[*].ToPort" --output text --profile $3)
do
  # echo $sgToport
   newstr=${myarr[$i]}
  myarr[$i]=${newstr/mytpt/"$sgToport"}
  let i++
  continue
done

let i=0
for sgProtocol in $(aws ec2 describe-security-groups --group-ids $2 --profile $3 --query "SecurityGroups[0].IpPermissions[*].IpProtocol" --output text --profile $3)
do
  if (( $sgProtocol != "-1" ))
  then
  #  echo $sgProtocol
   newstr=${myarr[$i]}
   myarr[$i]=${newstr/Ippt/"$sgProtocol"}
   let i++
  fi


done


str=""
let len=${#myarr[@]}
let len=$len-1
let i=0
for data in ${myarr[@]}
do
   str+=$data
   if (( $len != $i ))
   then
     str+=","
   fi
   let i++
done

echo "[$str]" > sg.json
sg_name="$5"
grpID=$(aws ec2 create-security-group --group-name "$sg_name" --description "$sg_name" --vpc-id $1 --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=$sg_name}]" --profile $4 --output text --query GroupId)

echo "$grpID"