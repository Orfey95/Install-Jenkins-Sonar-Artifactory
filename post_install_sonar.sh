#!/bin/bash

# POSTInstall Sonar on Centos 7

# Turn on logging
set -x

# Create user
login=$1
password=$2
name=$3
email=$4
sleep 5

curl -X POST -v -u admin:admin "http://localhost:9000/api/users/create?login=$login&password=$password&name=$name&email=$email"


