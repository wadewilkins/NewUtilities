#!/usr/bin/bash
##!/bin/bash
mount_point=$2
size_in_gb=$3
vault_base_path=$4
vault_token=$5

echo "Hi....."

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
IPS=$1
for x in $IPS
do
    # get the instance_id and ssh keyfile from aws.
    INSTANCE_ID=`aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,KeyName]' --filters Name=private-ip-address,Values=${x} --output text`
    #echo "instance:  $INSTANCE_ID"
    pem_file=$(echo "$INSTANCE_ID" | cut -f2) 
    echo "  #######################################################"
    echo "  # Working on $x..."
    echo "  #######################################################"
    echo "./aws_volume_grow.sh $x $mount_point $size_in_gb $PEM_LOCATION$pem_file.pem"
    if [ ! -f "$PEM_LOCATION$pem_file.pem" ]; then
      ./get_ssh_key_from_vault.sh $vault_base_path/$pem_file $pem_file $vault_token
      echo "Pem file:  $PEM_LOCATION$pem_file.pem"
      echo ""
      if [ ! -f "$PEM_LOCATION$pem_file.pem" ]; then
         echo "Unable to find key in vault"
         exit 1
      fi
    fi
    ./aws_volume_grow.sh $x $mount_point $size_in_gb $PEM_LOCATION$pem_file.pem
done
echo "#########################################################"
echo "## resize_volume_string.sh Complete!                    #"
echo "#########################################################"
IFS=$OIFS
