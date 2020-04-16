#!/bin/bash
ONE_IP=$1
MOUNT_POINT=$2
SIZE_IN_GB=$3
PEM_FILE=$4
echo "In aws_volume_grow.sh"
echo $ONE_IP
echo $MOUNT_POINT
echo $SIZE_IN_GB 
echo $PEM_FILE
echo
echo


# Convert the mount point into a Block device name
# This calls the helper script get_partition_on_ip.sh and cuts field 3 ot of it's output.
DEVICE_NAME=` ./get_partition_one_ip.sh $ONE_IP $PEM_FILE $MOUNT_POINT | cut -f9`
if [ -z "$DEVICE_NAME" ]
then 
   echo "Device is empty"
   DEVICE_NAME=` ./get_partition_one_ip.sh $ONE_IP $PEM_FILE $MOUNT_POINT | cut -f6`
fi
echo "Device=$DEVICE_NAME"

# This could be optimized.  Combine the call above with this one and cut the variable up.
PARTITION=` ./get_partition_one_ip.sh $ONE_IP $PEM_FILE $MOUNT_POINT | cut -f10`
echo "Partition=$PARTITION"

# Turn private ip address into INSTANCE_ID
INSTANCE_ID=`aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters Name=block-device-mapping.device-name,Values=${DEVICE_NAME} Name=private-ip-address,Values=${ONE_IP} --output text`
echo "InstanceID=$INSTANCE_ID"

# Get VOLUME_ID from INSTANCE_ID and DEVICE_NAME
VOLUME_ID=`aws ec2 describe-volumes --query "Volumes[*].{ID:VolumeId}" --filters Name=attachment.instance-id,Values=${INSTANCE_ID} Name=attachment.device,Values=${DEVICE_NAME} --output text`
echo "VolumeID=$VOLUME_ID"

# Enlarge the VOLUME
aws ec2 modify-volume --size ${SIZE_IN_GB}  --volume-id ${VOLUME_ID}

# Loop for up to 5 minutes or until the volume's status goes into "Opimizing" or "Complete"
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

# Make sure gdisk is installed.  sudo yum install gdisk -y
ssh -n -o "StrictHostKeyChecking=no" -i $PEM_FILE centos@$ONE_IP "sudo yum install gdisk -y"

# Valid partitions always end with a numeric.  If this last character is not numeric, we have a filesystem created on a unpartitioned volume
lastchar=${PARTITION: -1}
if [[ $lastchar =~ ^-?[0-9]+$ ]]
then
  echo "Numeric!!"
  ssh -n -o "StrictHostKeyChecking=no" -i $PEM_FILE centos@$ONE_IP "sudo growpart \"${DEVICE_NAME}\" 1 "
  ssh -n -o "StrictHostKeyChecking=no" -i $PEM_FILE centos@$ONE_IP "sudo xfs_growfs -d \"${MOUNT_POINT}\" "
else
  echo "Not Numeric"
  ssh -n -o "StrictHostKeyChecking=no" -i $PEM_FILE centos@$ONE_IP "sudo xfs_growfs -d \"${MOUNT_POINT}\" "
fi

exit 0


