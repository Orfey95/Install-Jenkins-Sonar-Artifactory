#!/bin/bash
# Install Artifactory in Ubuntu 18.04

# Check Java
java_status=$(dpkg -l | grep java)
if [[ $java_status == "" ]]
then
echo "Java is not installed"
sudo apt install -y openjdk-8-jre-headless
else echo "Java is already installed"
fi

# Install Artifactory
# wget https://bintray.com/artifact/download/jfrog/artifactory-debs/pool/main/j/jfrog-artifactory-oss-deb/jfrog-artifactory-oss-6.16.0.deb

# sudo wget -O artifactory-oss-6.16.0.tar.gz https://bintray.com/jfrog/artifactory/download_file?file_path=jfrog-artifactory-oss-6.16.0-sources.tar.gz
# tar xvzf artifactory-oss-6.16.0.tar.gz
# cd jfrog-artifactory-6.16.0/distribution/standalone/zip/src/main/install/bin


# CentOS
sudo yum install -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel wget nano
sudo wget -O artifactory-oss-6.16.0.rpm https://bintray.com/jfrog/artifactory-rpms/download_file?file_path=jfrog-artifactory-oss-6.16.0.rpm
sudo yum install -y artifactory-oss-6.16.0.rpm


sudo wget -c -O - "https://bintray.com/user/downloadSubjectPublicKey?username=jfrog" | sudo apt-key add -
echo "deb https://bintray.com/artifact/download/jfrog/artifactory-debs trusty main" | sudo tee -a /etc/apt/sources.list.d/artifactory-oss.list
sudo apt-get update
sudo apt-get -y install jfrog-artifactory-oss
sudo ufw allow 8081
