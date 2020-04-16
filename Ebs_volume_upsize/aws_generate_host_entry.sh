#!/bin/bash
ONE_IP=$1
CASS_DC=$2
CASS_RACK=$3

ID_AND_KEY=`aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,KeyName]' --filters Name=private-ip-address,Values=${ONE_IP} --output text`
#echo $ID_AND_KEY

INSTANSE_ID=$( echo "$ID_AND_KEY" |cut -f1 )
PEM_FILE=$( echo "$ID_AND_KEY" |cut -f2 )
echo "$ONE_IP	$PEM_FILE.pem	$CASS_DC	$INSTANSE_ID	$CASS_RACK"

