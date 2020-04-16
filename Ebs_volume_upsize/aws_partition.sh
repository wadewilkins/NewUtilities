#!/bin/bash
ONE_IP=$1
FILE_SYSTEM_TO_GROW=$2
PEM_FILE=$3
DEVICE_NAME=$4


#echo "sudo growpart $FILE_SYSTEM_TO_GROW 1"
#ssh -i ../../../.ssh/devdb.pem centos@$ONE_IP 'echo wade1'

echo "Growing partition, then filesystem...."
# sudo growpart /dev/xvdb 1
ssh -n -o "StrictHostKeyChecking=no" -i ../../../.ssh/$PEM_FILE centos@$ONE_IP 'sudo growpart \"${DEVICE_NAME}\" 1; sudo xfs_growfs -d \"${FILE_SYSTEM_TO_GROW}\" '

#echo "sudo xfs_growfs -d /data"
