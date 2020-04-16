#/usr/bin/bash
echo "In get_ssh_key_from_vault.sh"
VAULTPATH=$1
PEM_BASE=$2
echo "Vault path=$VAULTPATH"
TOKEN=$3

ACTION="READ"
SERVER=$(aws --region us-west-2  ec2 describe-instances --filters "Name=tag:Name,Values=sphinx_vault" | grep '"PrivateIpAddress"' | tr ',"' ' ' | cut -d: -f2 | tr -s ' ' | sort -u | tr '\n' ,  | tr -d ' ' | cut -d , -f 1)
echo "Vault server: $SERVER"

KeyValue=`echo ${KVPair//,/ }`

#echo "########################################################################"
#echo "#"
#echo "# IMPORTANT!"
#echo "# In this script, get_ssh_key_from_vault.sh, "
#echo "# The bellow variable VAULT_ADDR, is envrionment specific."
#echo "# It will need to be set for every env (dev,lab,prod)"
#echo "#"
#echo "########################################################################"

echo "
#export VAULT_ADDR=https://vault.lab.expts.net
export VAULT_ADDR=https://vault.platform.dexpts.net
#echo ""
/usr/local/bin/vault login $TOKEN
if [[ "$ACTION" == "LIST" ]]
then
   /usr/local/bin/vault list $VAULTPATH
elif [[ "$ACTION" == "READ" ]]
then
   /usr/local/bin/vault read $VAULTPATH
elif [[ "$ACTION" == "WRITE" ]]
then
   /usr/local/bin/vault write $VAULTPATH "$KeyValue"
else [[ "$ACTION" == "DELETE" ]]
   /usr/local/bin/vault delete $VAULTPATH
fi
" > /tmp/deploy.sh

echo $SERVER
scp -i /var/lib/jenkins/.ssh/app.pem -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /tmp/deploy.sh centos@$SERVER:/home/centos/deploy.sh
PEM_LINES=`ssh -tt -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /var/lib/jenkins/.ssh/app.pem centos@$SERVER "sudo bash /home/centos/deploy.sh"`

#Set the field separator to new line

# This was harder than I had hoped.
# It seems vault replaces \n with ' '.
# I converted back.
# Of coarse, the spaces in the first and last lines (eg: BEGIN RSA PRIVATE KEY) are valid.
# Seems a bit hacky, Maybe vault can be taught to store newline characters?
#
#
#Try to iterate over each line
echo "For loop:"
PEM_FILE_NAME="$PEM_LOCATION$PEM_BASE.pem" 
IFS=$'\n'
GOOD_DATA="0"
for item in $PEM_LINES
do
    if [[ "$item" == *"BEGIN RSA PRIVATE KEY"* ]]; then
      echo "-----BEGIN RSA PRIVATE KEY-----" >$PEM_FILE_NAME
      tmp=${item#*----- } 
      tmp2=${tmp::-34} 
      tmp3=`echo $tmp2 | tr " " "\n"`
      echo "$tmp3" >>$PEM_FILE_NAME
      echo "-----END RSA PRIVATE KEY-----" >>$PEM_FILE_NAME
      IFS='|'
      IFS=$'\n'
      GOOD_DATA="1"
    fi
done
if [[ "$PEM_FILE_NAME" != "START" ]]; then
  chmod 400 $PEM_FILE_NAME
fi




