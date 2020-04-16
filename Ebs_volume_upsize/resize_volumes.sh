#!/bin/bash
host_file=$1
mount_point=$2
size_in_gb=$3
#
# example call:
# nohup ./resize_volumes.sh hosts.one.maui /data 2100 &
#
if [ -z "$PEM_LOCATION" ]
then
      PEM_LOCATION="/tmp/"
fi

while IFS=$'\t' read -r node_ip_address pem_file
do
  echo "IP: $node_ip_address FS: $mount_point SIZE: $size_in_gb"
  [[ $node_ip_address =~ ^#.* ]] && continue
  ./aws_volume_grow.sh $node_ip_address $mount_point $size_in_gb $PEM_LOCATION$pem_file
done < $host_file

