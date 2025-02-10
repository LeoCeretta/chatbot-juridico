import boto3
import time

logs = boto3.client("logs",region_name= "us-east-1")

LOG_GROUP='LexScripta_Logs'
LOG_STREAM="General_Logs"

groups = []
paginator = logs.get_paginator('describe_log_groups')
for page in paginator.paginate():
  for group in page['logGroups']:
    groups.append(group['logGroupName'])

if str(LOG_GROUP) not in groups:
  logs.create_log_group(logGroupName=LOG_GROUP)
  logs.create_log_stream(logGroupName=LOG_GROUP, logStreamName=LOG_STREAM)

timestamp = int(round(time.time() * 1000))

def send_logs(log):
  response = logs.put_log_events(
    logGroupName=LOG_GROUP,
    logStreamName=LOG_STREAM,
    logEvents=[
      {
        "timestamp": timestamp,
        "message": f"{time.strftime('%Y-%m-%d %H:%M:%S')} - {str(log)}"
      }
    ]
  )
  return response