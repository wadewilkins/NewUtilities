#!/usr/bin/env python3
######################################################################################################################
#
# Restful crontab
# Supports, Add scheduled task, delete one task, query one task, query all tasks.
#
# To run:  "run_local.sh"
# To test: "run_tests.sh"
#
# Add task example:  
# curl  localhost:5000/todos -d '{"task": "echo test1 >>/tmp/output.txt", "schedule": "* * * * *"}' -H 'Content-Type: application/json'
#
# Query ALL task example:
# curl http://localhost:5000/todos
#
# Query One task example:
# curl -X PUT  http://localhost:5000/todos -d '{"comment": "effdd5d6096b11ea80a60242ac110002"}' -H 'Content-Type: application/json'
#
# Delete one task example:
# curl -silent -X DELETE  http://localhost:5000/todos -d '{"comment": "2222"}'  -H 'Content-Type: application/json'
#
# The add process creates a unique TASK_ID.  IT is stored in the crontab's comment field.
# This may be a bit confusing.  comment=task_id
# It is a unique identifier so we can query or delete a given task.
#
######################################################################################################################

from flask import Flask,jsonify,json
from flask_restful import reqparse, abort, Api, Resource
from crontab import CronTab
import re
import uuid

app = Flask(__name__)
api = Api(app)


parser = reqparse.RequestParser()
parser.add_argument('task')
parser.add_argument('schedule')
parser.add_argument('comment')

# TodoList
# shows a list of all todos, and lets you POST to add new tasks
class TodoList(Resource):
    def get(self):
        todo_current=[]
        my_cron = CronTab(user='root')
        for job in my_cron:
           test = str(job)
           cron_array = test.split()
           oneJob ={
             'task': job.command,
             'comment': job.comment,
             'schedule': cron_array[0] +' '+cron_array[1] +' '+cron_array[2] +' '+cron_array[3] +' '+cron_array[4] +' ' 
           }
           todo_current.append(oneJob)
        jsonStr = json.dumps(todo_current)
        return jsonify(CRON=jsonStr)
    def put(self):
        args = parser.parse_args()
        todo_current=[]
        my_cron = CronTab(user='root')
        list = my_cron.find_comment(args['comment'])
        for job in list:
           test = str(job)
           cron_array = test.split()
           oneJob ={
             'task': job.command,
             'comment': job.comment,
             'schedule': cron_array[0] +' '+cron_array[1] +' '+cron_array[2] +' '+cron_array[3] +' '+cron_array[4] +' '
           }
           todo_current.append(oneJob)
        jsonStr = json.dumps(todo_current)
        return jsonify(GET_CRON=jsonStr)
        #return args['comment']
    def post(self):
        args = parser.parse_args()
        if BadSchedule(args['schedule']):
           return "bad schedule", 201
        if BadTask(args['task']):
           return "bad task", 201
        my_cron = CronTab(user='root')
        job = my_cron.new(command=args['task'])
        job.setall(args['schedule'])
        modified_comment = str(uuid.uuid1().hex)
        #job.set_comment(args['comment'])
        job.set_comment(modified_comment)
        my_cron.write()
        return  {'task identifier': modified_comment}
    def delete(self):
        args = parser.parse_args()
        todo_current=[]
        my_cron = CronTab(user='root')
        list = my_cron.find_comment(args['comment'])
        for job in list:
           my_cron.remove(job)
        my_cron.write()
        return 'Job removed', 204

##
## Actually setup the Api resource routing here
##
api.add_resource(TodoList, '/todos')

def BadSchedule( schedule ):
    # Cannot be null
    if not schedule:
      return True
    # Must cover all the cron scheduling options
    number_schedule_elements = schedule.split()
    if len(number_schedule_elements) < 5:
      return True
    validate_crontab_time_format_regex = re.compile(\
        "{0}\s+{1}\s+{2}\s+{3}\s+{4}".format(\
            "(?P<minute>\*|[0-5]?\d)",\
            "(?P<hour>\*|[01]?\d|2[0-3])",\
            "(?P<day>\*|0?[1-9]|[12]\d|3[01])",\
            "(?P<month>\*|0?[1-9]|1[012])",\
            "(?P<day_of_week>\*|[0-6](\-[0-6])?)"\
        ) # end of str.format()
    ) # end of re.compile()
    try:
       dict = validate_crontab_time_format_regex.match(schedule).groupdict()
    except:
      return True

    return False
def BadTask( task ):
    if not task:
      return True
    return False

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
