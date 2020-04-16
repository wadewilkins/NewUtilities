#!/bin/bash
# Call me example
# ./get_partition.sh hosts.maui /dev/xvdb 2>&1 |grep internal
#
#
# https://hackernoon.com/tutorial-how-to-extend-aws-ebs-volumes-with-no-downtime-ec7d9e82426e
node_ip_address=$1
pem_file=$2
mount_point=$3

./aws_get_part_size.sh $node_ip_address $mount_point $pem_file 2>/dev/null



