#!/usr/bin/env python

import json

json_string = '{"first_name": "Wade", "last_name":"Rossum"}'

parsed_json = json.loads(json_string)

print(parsed_json['first_name'])

d = {
    'first_name': 'Guido',
    'second_name': 'Rossum',
    'titles': ['BDFL', 'Developer'],
}

new_json_string = json.dumps(d)
new_parsed_json = json.loads(new_json_string)


print(json.dumps(d,indent=10))


print(new_parsed_json['first_name'])

#with open("data_file.json", "w") as write_file:
#    json.dump(new_parsed_json, write_file)



with open("data_file.json", "r") as read_file:
    data = json.load(read_file)
new_parsed_json = json.load(data)
print(new_parsed_json['first_name'])





