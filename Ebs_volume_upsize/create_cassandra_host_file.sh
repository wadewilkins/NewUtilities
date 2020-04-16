#!/bin/bash
ONE_IP=$1
PEM_FILE=$2
HOST_FILE=$3

if [ -z "$PEM_LOCATION" ]
then
      PEM_LOCATION="/tmp/"
fi
OLDIFS="$IFS"
IFS=$'\n' # bash specific


ALL_IPS=`ssh -n -o "StrictHostKeyChecking=no" -i $PEM_LOCATION$PEM_FILE centos@$ONE_IP "nodetool status | egrep 'UN|DN|UJ|Datacenter'  | awk '{printf(\"%s\\t%s\\t%s\\r\\n\",\\$1,\\$2,\\$8)}'"`
#echo "$ALL_IPS"
CURRENT_DC=""


while IFS= read -r line; do
    #echo "... $line ..."
    for word in $line
    do
       TYPE=`echo ${word} |  awk  '{print $1}'`
       if [ $TYPE == "Datacenter:" ]; then
          CURRENT_DC=`echo ${word} | awk '{print $2}'`
          #echo $CURRENT_DC
          continue
       fi
       RACK=`echo ${word} | awk '{print $3}'`
       LOOP_IP=`echo ${word} |  awk  '{print $2}'`
       ./aws_generate_host_entry.sh $LOOP_IP $CURRENT_DC $RACK >>$HOST_FILE
    done
done <<< "$ALL_IPS"

IFS="$OLDIFS"
