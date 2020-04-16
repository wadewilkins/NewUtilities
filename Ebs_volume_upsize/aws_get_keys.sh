#!/bin/bash
ONE_IP=$1

INSTANCE_ID=`aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,KeyName]' --filters Name=private-ip-address,Values=${ONE_IP} --output text`
echo $INSTANCE_ID

