#!/bin/bash
#Script to create AMI of server on daily basis and deleting AMI older than n no of days

echo -e "----------------------------------\n   `date`   \n----------------------------------"

#To create a unique AMI name for this script
echo "instance-vpc-prod-app-01-`date +%d%b%y`" > /tmp/aminame.txt

echo -e "Starting the Daily AMI creation: `cat /tmp/aminame.txt`\n"

#To create AMI of defined instance
aws ec2 create-image --instance-id i-f7f3942e --name "`cat /tmp/aminame.txt`" --description "This is for Daily auto AMI creation" --no-reboot | grep -ir ami | awk '{print $4}' > /tmp/amiID.txt

#Showing the AMI name created by AWS
echo -e "AMI ID is: `cat /tmp/amiID.txt`\n"

echo -e "Looking for AMI older than 3 days:\n "

#Finding AMI older than 3 days which needed to be removed
echo "instance-`date +%d%b%y --date '4 days ago'`" > /tmp/amidel.txt

#Finding Image ID of instance which needed to be Deregistered
aws ec2 describe-images --filters "Name=name,Values=`cat /tmp/amidel.txt`" | grep -ir imageid | awk '{ print  $4 }' > /tmp/imageid.txt

echo -e "Following AMI is found : `cat /tmp/imageid.txt`\n"

#Find the snapshots attached to the Image need to be Deregister
aws ec2 describe-images --image-ids `cat /tmp/imageid.txt` | grep snap | awk ' { print $4 }' > /tmp/snap.txt

echo -e "Following are the snapshots associated with it : `cat /tmp/snap.txt`:\n "

echo -e "Starting the Deregister of AMI... \n"

#Deregistering the AMI
aws ec2 deregister-image --image-id `cat /tmp/imageid.txt`

echo -e "\nDeleting the associated snapshots.... \n"

#Deleting snapshots attached to AMI
for i in `cat /tmp/snap.txt`;do aws ec2 delete-snapshot --snapshot-id $i ; done
