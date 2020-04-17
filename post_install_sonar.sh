#!/bin/bash

# POSTInstall Sonar on Centos 7

# Turn on logging
set -x

while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' -u admin:admin -X POST http://localhost:9000/api/users/change_password --data 'login=admin&password=replace_password&previousPassword=admin')" != "204" ]]; 
do sleep 5; 
done

