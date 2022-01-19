#!/bin/env python3
import json
import os
import requests
import sys

# Send information to web URL after Terraform finishes provisioning


def sendToAPI(myhost,myip,myenv,myzabtemplate,mypuppetorg,myplatform,myrootuser,mylogingroup,myrglocation,myrgname,mypatchtime,myappsol,mydomain):
  url = 'https://provisionapi.website.com/azure_postbuild'
  token = os.environ['LINUX_API']
  headers = {'Content-Type': 'application/json'}
  data = {
    "host": myhost,
    "env": myenv,
    "ip": myip,
    "zabtemplates": myzabtemplate,
    "puppetorg": mypuppetorg,
    "platform": myplatform,
    "rootuser": myrootuser,
    "logingroup": mylogingroup,
    "rglocation": myrglocation,
    "rgname": myrgname,
    "patchtime": mypatchtime,
    "appsol": myappsol,
    "domain": mydomain,
    "token": token
  }
  for item in data:
    if item!="token":
      print(f"{item}:{data[item]}")
  data=json.dumps(data)
  response = requests.post(url,  headers=headers, data=data)
  print(response.content)

  if response.status_code == requests.codes.ok:
    sys.exit()
  else:
    print("Invalid HTTP return code: " + str(response.status_code))
    sys.exit(3)

def main(argv=None):
  myhost=str(sys.argv[1])
  myip=str(sys.argv[2])
  myenv=str(sys.argv[3])
  myzabtemplate=str(sys.argv[4])
  mypuppetorg=str(sys.argv[5])
  myplatform=str(sys.argv[6])
  myrootuser=str(sys.argv[7])
  mylogingroup=str(sys.argv[8])
  myrglocation=str(sys.argv[9])
  myrgname=str(sys.argv[10])
  mypatchtime=str(sys.argv[11])
  myappsol=str(sys.argv[12])
  mydomain=str(sys.argv[13])
  sendToAPI(myhost,myip,myenv,myzabtemplate,mypuppetorg,myplatform,myrootuser,mylogingroup,myrglocation,myrgname,mypatchtime,myappsol,mydomain)


if __name__ == '__main__':
  sys.exit(main())
