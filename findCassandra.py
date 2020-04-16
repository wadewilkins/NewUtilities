#!/usr/bin/env python
import sys
import boto3
import pprint
from ConfigParser import SafeConfigParser
import os

os.system('clear')
print ""
parser = SafeConfigParser()
parser.read('/root/.aws/credentials')
pp = pprint.PrettyPrinter(indent=4)
   
allgroups = []
cassandra_candidates = []

for section_name in parser.sections():
   #print 'Section:', section_name
   #print '  Options:', parser.options(section_name)
   v_aws_access_key_id = ''
   v_aws_secret_access_key = ''
   v_aws_region = ''
   for name, value in parser.items(section_name):
       if name == 'aws_access_key_id':
          v_aws_access_key_id = value
       if name == 'aws_secret_access_key':
          v_aws_secret_access_key = value
       if name == 'region':
          v_aws_region = value
          #print '  %s = %s' % (name, value)
   # make connection
   ec2 = boto3.resource(
     'ec2',
     region_name=v_aws_region,
     aws_access_key_id=v_aws_access_key_id,
     aws_secret_access_key=v_aws_secret_access_key
    )
   ec2client = boto3.client(
     'ec2',
     region_name=v_aws_region,
     aws_access_key_id=v_aws_access_key_id,
     aws_secret_access_key=v_aws_secret_access_key
    )

   # Get all Cassandra security groups names
   groups = ec2.security_groups.filter( Filters=[{'Name': 'ip-permission.to-port', 'Values': ['9042'] }])
   #groups = ec2client.get_all_security_groups(Filters=[{'Name': 'ip-permission.to-port', 'Values': ['9042'] }])
   for groupobj in groups:
       allgroups.append(groupobj.group_name)
   #pp.pprint(sorted(allgroups))

   # Get [running|stopped] instances security groups
   # See if they have one of the suspected Cassandra security groups
   groups_in_use = []
   for state in ['running','stopped']:
       response = ec2client.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values':  [state] }])
       for reservation in response["Reservations"]:
           for inst in reservation["Instances"]:
               for group in inst["SecurityGroups"]:
                  if group["GroupName"] in allgroups:
                      cassandra_candidates.append(inst["PrivateDnsName"])

print "The list of machines with port 9042 open\n"
for private_ip in cassandra_candidates:
   print private_ip
#pp.pprint(sorted(cassandra_candidates))
print "\nTotal of %d machines that should be investigated for DSE licenses.\n\n" % (len(cassandra_candidates))


