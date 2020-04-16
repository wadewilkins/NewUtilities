#!/bin/bash
# Call me example
# ./report_volumes.sh hosts.maui /data/
#
# https://hackernoon.com/tutorial-how-to-extend-aws-ebs-volumes-with-no-downtime-ec7d9e82426e
host_file=$1
mount_point=$2

if [ -z "$PEM_LOCATION" ]
then
      PEM_LOCATION="/tmp/"
fi
echo
echo
echo -e "IP\t\tMount\tUsed\tAvailable\tFileSystem\tDevice size\tDevice\t\tPartition"
while IFS=$'\t' read -r node_ip_address pem_file
do
  #echo "IP: $node_ip_address PEM: $pem_file"
  [[ $node_ip_address =~ ^#.* ]] && continue
  ./aws_get_part_size.sh $node_ip_address $mount_point $PEM_LOCATION$pem_file 2>/dev/null
done < $host_file


