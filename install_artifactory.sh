#!/bin/bash

# Install Artifactory in Centos 7

# Turn on logging
set -x

# Check Java
java_status=$(sudo rpm -qa | grep java)
if [[ $java_status == "" ]]
then
echo "Java is not installed"
yum install -y java-11-openjdk-devel
else echo "Java is already installed"
fi

# Set JAVA_HOME
echo "export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))" >> /etc/profile
echo "export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile
echo "export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar" >> /etc/profile
source /etc/profile

# Add Artifactory RPM repository
curl -sL https://bintray.com/jfrog/artifactory-rpms/rpm | tee /etc/yum.repos.d/bintray-jfrog-artifactory-rpms.repo

# Install Artifactory
artifactory_status=$(sudo rpm -qa | grep artifactory)
if [[ $artifactory_status == "" ]]
then
echo "Artifactory is not installed"
yum -y install jfrog-artifactory-oss wget
else echo "Java is already installed"
fi

# Set admin password
curl -XPATCH -uaccess-admin:password http://localhost:8040/access/api/v1/users/admin -H "Content-Type: application/json" -d '{ "password": "12345678" }'

# Start Artifactory
systemctl start artifactory
systemctl status artifactory

# Install Artifactory CLI
curl -fL https://getcli.jfrog.io | sh

# Create maven repository
