#!/bin/bash

# Install Artifactory on Centos 7

set -xe

# Variables
admin_password=$1

# Check Java
if ! rpm -qa | grep java; then
	echo "Java is not installed"
	yum install -y java-11-openjdk-devel
else 
	echo "Java is already installed"
fi

# Add Artifactory RPM repository
curl -sL https://bintray.com/jfrog/artifactory-rpms/rpm | tee /etc/yum.repos.d/bintray-jfrog-artifactory-rpms.repo

# Install Artifactory
if ! rpm -qa | grep artifactory; then
	echo "Artifactory is not installed"
	yum -y install jfrog-artifactory-oss wget
else 
	echo "Artifactory is already installed"
fi

# Start Artifactory
systemctl start artifactory
systemctl status artifactory

# Set admin password
curl -XPATCH -uadmin:password http://localhost:8081/access/api/v1/users/admin -H "Content-Type: application/json" -d '{ "password": "'"$admin_password"'" }'
