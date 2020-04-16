
  
# https://hackernoon.com/tutorial-how-to-extend-aws-ebs-volumes-with-no-downtime-ec7d9e82426e
hosts_file=$1
file_system_to_grow=$2
size_in_gb=$3

while IFS=$'\t' read -r node_ip_address pem_file
do
  echo "IP: $node_ip_address PEM: $pem_file"
  [[ $node_ip_address =~ ^#.* ]] && continue
  ./aws_partition.sh $node_ip_address $file_system_to_grow $pem_file
done < $hosts_file


