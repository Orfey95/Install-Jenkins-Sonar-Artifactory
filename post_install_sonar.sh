#!/bin/bash

# POSTInstall Sonar on Centos 7

# Turn on logging
#set -x

#until $(curl --output /dev/null --silent --head --fail http://localhost:9000); do
#sleep 3
#done

curl -u admin:admin -X POST http://localhost:9000/api/users/change_password --data 'login=admin&password=replace_password&previousPassword=admin'



