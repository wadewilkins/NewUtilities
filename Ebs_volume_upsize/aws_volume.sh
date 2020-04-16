#!/bin/bash
ONE_IP=$1
MOUNT_POINT=$2
SIZE_IN_GB=$3
PEM_FILE=$4

# Convert the mount point into a Block device name
DEVICE_NAME=` ./get_partition_one_ip.sh $ONE_IP $PEM_FILE $MOUNT_POINT | cut -f3`
#DEVICE_NAME=`ssh -n -o "StrictHostKeyChecking=no" -i ../../../.ssh/$PEM_FILE centos@$ONE_IP "df -h |grep \"${MOUNT_POINT}\" |awk -v ORS= '{printf \"%s\t%s\t%s\t%s\t%s\t\",\"${ONE_IP}\", \"${MOUNT_POINT}\", \$1, \$2, \$3}'; lsblk |grep data |awk '{print \$4}' 2>/dev/null"`

# Turn private ip address into INSTANCE_ID
INSTANCE_ID=`aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters Name=block-device-mapping.device-name,Values=${DEVICE_NAME} Name=private-ip-address,Values=${ONE_IP} --output text`
#echo $INSTANCE_ID

# Get VOLUME_ID from INSTANCE_ID and MOUNT_POINT (passed to this script)
#echo "aws ec2 describe-volumes --query "Volumes[*].{ID:VolumeId}" --filters Name=attachment.instance-id,Values=${INSTANCE_ID} Name=attachment.device,Values=${DEVICE_NAME} --output text"
VOLUME_ID=`aws ec2 describe-volumes --query "Volumes[*].{ID:VolumeId}" --filters Name=attachment.instance-id,Values=${INSTANCE_ID} Name=attachment.device,Values=${DEVICE_NAME} --output text`
#echo $VOLUME_ID

# Enlarge the VOLUME
aws ec2 modify-volume --size ${SIZE_IN_GB}  --volume-id ${VOLUME_ID}

# Loop for 5 minutes or until the volume's status goes into "Opimizing" or "Complete"
date1=$(date +"%s")
date2=$(date +"%s")
DIFF=$(($date2-$date1))
while [ $DIFF -lt 300 ]
do
  STATUS=`aws ec2 describe-volumes-modifications --volume-id ${VOLUME_ID} --output text`
  COMPLETED=`echo ${STATUS} | grep "completed\|optimizing" | wc -l`
  if [ "$COMPLETED" -gt 0 ]
  then
    break  # status is completed or optimizing, Skip entire rest of loop.
  fi
  echo "Waiting"
  sleep 10
  date2=$(date +"%s")
  DIFF=$(($date2-$date1))
done

# Is the loop done because time limit (fail), if not, Enlarge the partition and then the filesystem.
if [ "$DIFF" -gt 299 ]
then
  echo "fail"
  exit 1
fi
  ssh -n -o "StrictHostKeyChecking=no" -i ../../../.ssh/$PEM_FILE centos@$ONE_IP "sudo growpart \"${DEVICE_NAME}\" 1; sudo xfs_growfs -d \"${MOUNT_POINT}\" "
exit 0


