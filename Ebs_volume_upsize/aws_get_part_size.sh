!/bin/bash
ONE_IP=$1
MOUNT_POINT=$2
PEM_FILE=$3

# lsblk -no size,name,type,mountpoint,pkname |grep /data |awk '{printf("%s\t\t%s\t%s\t%s\n",$1,$2,$3,$5)}'

SYSTEM_TYPE=`ssh -n -o "StrictHostKeyChecking=no" -i $PEM_FILE centos@$ONE_IP "lsblk -no type,mountpoint |grep \"${MOUNT_POINT}\" |awk '{printf(\"%s\",\\$1)}'"`

if [ $SYSTEM_TYPE == "part" ]; then
  ssh -n -o "StrictHostKeyChecking=no" -i $PEM_FILE centos@$ONE_IP "df -h |grep \"${MOUNT_POINT}\" |awk -v ORS= '{printf \"%s\t%s\t%s\t%s\t\t%s\t\",\"${ONE_IP}\", \"${MOUNT_POINT}\", \$3, \$2, \$1}'; lsblk -no size,pkname,type,mountpoint,name |grep \"${MOUNT_POINT}\" |awk '{printf(\"%s\\t\\t/dev/%s\\t/dev/%s\\t%s\\n\",\$1,\$2,substr(\$5,3),\$3)}'" 
else
  ssh -n -o "StrictHostKeyChecking=no" -i $PEM_FILE centos@$ONE_IP "df -h |grep \"${MOUNT_POINT}\" |awk -v ORS= '{printf \"%s\t%s\t%s\t%s\t\t%s\t\",\"${ONE_IP}\", \"${MOUNT_POINT}\", \$3, \$2, \$1}'; lsblk -no size,name,type,mountpoint,pkname |grep \"${MOUNT_POINT}\" |awk '{printf(\"%s\\t\\t/dev/%s\\t%s\\t\\t\\t%s\\n\",\$1,\$2,\$3,\$5)}'" 
fi
