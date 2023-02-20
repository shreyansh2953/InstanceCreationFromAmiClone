#! /bin/bash


# ./amiClone.sh profile_name date
InstanceList="Provide string with seperated commas"
declare -a amiIdArr

amiIdArr=()

Instancearr=(${InstanceList//,/ })
for InstanceId in "${Instancearr[@]}"
do
echo "Cloning InstanceId:- $InstanceId"
declare -a myarr
myarr=()
for data in $(aws ec2 describe-instances --instance-ids $InstanceId --query 'Reservations[*].Instances[*].[InstanceType,Placement.AvailabilityZone,NetworkInterfaces[*].Groups[*].GroupId]' --output text --profile $1)
do 
   myarr+=($data)
done

echo "InstanceType:- ${myarr[0]}"
echo "AvailabilityZone:- ${myarr[1]}"
echo "SecurityGroup:- ${myarr[2]}"
Name_Tag=$(aws ec2 describe-instances --instance-ids $InstanceId --query 'Reservations[*].Instances[*].[Tags[?Key == `Name`] | [0].Value]' --output text --profile $1)

echo "$Name_Tag"

Ec2=${Name_Tag/-D/-T}
echo "$Ec2"
arrIN=(${Name_Tag// / })

Ami_Name="${arrIN[0]}-$2"
echo "$Ami_Name"
Ami_Id=$(aws ec2 create-image --instance-id $InstanceId --name "$Ami_Name" --description "$Ami_Name" --tag-specifications "ResourceType=image,Tags=[{Key=Name,Value=$Ami_Name},{Key=Ec2,Value=$Ec2},{Key=Type,Value=${myarr[0]}},{Key=Az,Value=${myarr[1]}},{Key=Sg,Value=${myarr[2]}}]" --query ImageId --output text --profile $1)
echo $Ami_Id

amiIdArr+=($Ami_Id)
done



for amiId in "${amiIdArr[@]}"
do

   echo ${amiId} >> amiId.txt

done
