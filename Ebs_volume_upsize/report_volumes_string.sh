#!/usr/bin/bash
##!/bin/bash
IPS=$1
mount_point=$2
size_in_gb=$3
vault_base_path=$4
vault_token=$5

#
# example call:
# nohup ./resize_volumes.sh hosts.one.maui /data 2100 &
#
if [ -z "$PEM_LOCATION" ]
then
      PEM_LOCATION="/tmp/"
fi

OIFS=$IFS
IFS=','
echo
echo
echo "#########################################################"
echo "## Report the volumes after resizing                    #"
echo "#########################################################"
echo
echo -e "IP\t\tMount\tUsed\tAvailable\tFileSystem\tDevice size\tDevice\t\tPartition"
AT_LEAST_ONE_MACHINE_DID_NOT_SIZE_RIGHT=0

for x in $IPS
do
    # get the instance_id and ssh keyfile from aws.
    INSTANCE_ID=`aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,KeyName]' --filters Name=private-ip-address,Values=${x} --output text`
    #echo "instance:  $INSTANCE_ID"
    pem_file=$(echo "$INSTANCE_ID" | cut -f2) 
    if [ ! -f "$PEM_LOCATION$pem_file.pem" ]; then
      ./get_ssh_key_from_vault.sh $vault_base_path/$pem_file $pem_file
      echo "Pem file:  $PEM_LOCATION$pem_file.pem"
      echo ""
      if [ ! -f "$PEM_LOCATION$pem_file.pem" ]; then
         echo "Unable to find key ($PEM_LOCATION$pem_file.pem) in vault"
         exit 1
      fi
    fi
    output_line=`./aws_get_part_size.sh $x $mount_point $PEM_LOCATION$pem_file.pem 2>/dev/null`
    echo $output_line
    AVAILABLE=$( echo "$output_line" |cut -f4 )
    if [ "${AVAILABLE: -1}" == "T" ]
      then
      NUMERIC_AVAILABLE=${AVAILABLE::-1}
      t=$(expr $NUMERIC_AVAILABLE*1000 | bc)
      if [ $t < $size_in_gb ] 
      then
          echo "Filesystem did not grow.  Numeric Available: $NUMERIC_AVAILABLE,  Rounded Available: $t, Asked:  $size_in_gb"
          AT_LEAST_ONE_MACHINE_DID_NOT_SIZE_RIGHT=1
      elif [ $t > $size_in_gb ]
      then
          echo "Filesystem was already larger than expec0ted.  Available: $NUMERIC_AVAILABLE . Asked:  $size_in_gb"
          AT_LEAST_ONE_MACHINE_DID_NOT_SIZE_RIGHT=1
      fi
    else 
      #ToDo:  Handle GB
      echo $AVAILABLE
    fi
done
if (( AT_LEAST_ONE_MACHINE_DID_NOT_SIZE_RIGHT > 0 )); then
    echo
    echo "At least one machine is wrong"
    exit 1
fi
IFS=$OIFS
echo 
echo

