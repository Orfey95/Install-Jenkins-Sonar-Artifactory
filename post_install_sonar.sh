#!/bin/bash

# POSTInstall Sonar on Centos 7

# Turn on logging
set -x

# Create user
password=$1

curl -u admin:admin -X POST http://localhost:9000/api/users/change_password --data 'login=admin&password=$password&previousPassword=admin'



