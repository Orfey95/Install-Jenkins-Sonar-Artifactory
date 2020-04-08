#!/bin/bash

# Install Jenkins on Ubuntu 18.04

# Turn on logging
set -x

# Check Java
java_status=$(dpkg -l | grep java)
if [[ $java_status == "" ]]
then
echo "Java is not installed"
apt update
apt install -y openjdk-8-jre-headless
else echo "Java is already installed"
fi

# Install Jenkins
jenkins_status=$(dpkg -l | grep jenkins)
if [[ $jenkins_status == "" ]]
then
echo "Jenkins is not installed"
jenkins_LTS=$1
if [ $# == 0 ]
then
echo "You forgot to enter LTS version"
exit 1
fi
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
sh -c 'echo deb http://pkg.jenkins-ci.org/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt update
apt install -y jenkins=$jenkins_LTS
systemctl start jenkins
systemctl enable jenkins
systemctl status jenkins
else echo "Jenkins is already installed"
fi

# Create admin user
admin_login=$2
admin_password=$3
if [ $# != 7 ]
then
echo "You forgot to enter script parameters (admin login and password)"
exit 1
fi
echo "Admin login will be: $admin_login"
echo "Admin password will be: $admin_password"
test -f $HOME/jenkins-cli.jar
if [ $? == 1 ]
then
wget --retry-connrefused --waitretry=10 --read-timeout=10 --timeout=10 -t 0 --retry-on-http-error=503 -P $HOME http://localhost:8080/jnlpJars/jenkins-cli.jar
fi
temp_pass=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount('$admin_login', '$admin_password')" | java -jar $HOME/jenkins-cli.jar -s "http://localhost:8080" -auth admin:$temp_pass -noKeyAuth groovy = –

# Install Jenkins plugins: Role-Based, Git, Pipeline, BlueOcean, BackUp, SonarQube, Artifactory
java -jar $HOME/jenkins-cli.jar -s "http://localhost:8080/" -auth admin:$temp_pass install-plugin \
role-strategy \
git \
workflow-aggregator \
blueocean \
backup \
sonar \
artifactory \
locale \
maven-plugin \
ssh-agent \
ssh-slaves \
-restart

# Remove jenkins cli
rm $HOME/jenkins-cli.jar

# Integration Sonar and Artifactory
#Variables
sonar_ip=$4
sonar_name=$5
artifactory_ip=$6
artifactory_name=$7

rm /var/lib/jenkins/config.xml
wget https://raw.githubusercontent.com/Orfey95/Install-Jenkins-Sonar-Artifactory/master/jenkins/config.xml -P /var/lib/jenkins
sed -i 's!<version>[0-9.]\+</version>!<version>replace_it</version>!' /var/lib/jenkins/config.xml
sed -i "s/replace_it/$jenkins_LTS/" /var/lib/jenkins/config.xml

rm /var/lib/jenkins/credentials.xml
wget https://raw.githubusercontent.com/Orfey95/Install-Jenkins-Sonar-Artifactory/master/jenkins/credentials.xml -P /var/lib/jenkins

wget https://raw.githubusercontent.com/Orfey95/Install-Jenkins-Sonar-Artifactory/master/jenkins/hudson.plugins.sonar.SonarGlobalConfiguration.xml -P /var/lib/jenkins
sed -i "s/replace_ip/$sonar_ip/" /var/lib/jenkins/hudson.plugins.sonar.SonarGlobalConfiguration.xml
sed -i "s/replace_name/$sonar_name/" /var/lib/jenkins/hudson.plugins.sonar.SonarGlobalConfiguration.xml

wget https://raw.githubusercontent.com/Orfey95/Install-Jenkins-Sonar-Artifactory/master/jenkins/hudson.plugins.sonar.SonarRunnerInstallation.xml -P /var/lib/jenkins
sed -i "s/replace_name/$sonar_name/" /var/lib/jenkins/hudson.plugins.sonar.SonarRunnerInstallation.xml

wget https://raw.githubusercontent.com/Orfey95/Install-Jenkins-Sonar-Artifactory/master/jenkins/org.jfrog.hudson.ArtifactoryBuilder.xml -P /var/lib/jenkins
sed -i "s/replace_ip/$artifactory_ip/" /var/lib/jenkins/org.jfrog.hudson.ArtifactoryBuilder.xml
sed -i "s/replace_name/$artifactory_name/" /var/lib/jenkins/org.jfrog.hudson.ArtifactoryBuilder.xml

# Change owner
chown -R jenkins:jenkins /var/lib/jenkins

# Restart Jenkins
systemctl restart jenkins
