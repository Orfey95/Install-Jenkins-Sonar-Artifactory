#!/bin/bash
# Install Artifactory in Centos 7

# Check Java
java_status=$(sudo rpm -qa | grep java)
if [[ $java_status == "" ]]
then
echo "Java is not installed"
sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
else echo "Java is already installed"
fi

# Set JAVA_HOME
export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
source ~/.bashrc
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar

# Add Artifactory RPM repository
curl -sL https://bintray.com/jfrog/artifactory-rpms/rpm | sudo tee /etc/yum.repos.d/bintray-jfrog-artifactory-rpms.repo

# Install Artifactory
artifactory_status=$(sudo rpm -qa | grep artifactory)
if [[ $artifactory_status == "" ]]
then
echo "Artifactory is not installed"
sudo yum -y install jfrog-artifactory-oss wget
else echo "Java is already installed"
fi
sudo systemctl start artifactory.service

# Install Artifactory CLI
curl -fL https://getcli.jfrog.io | sh

# Create maven repository
