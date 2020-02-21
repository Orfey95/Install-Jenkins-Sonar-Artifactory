#!/bin/bash
# Install Jenkins in Ubuntu 18.04

# Check Java
java_status=$(dpkg -l | grep java)
if [[ $java_status == "" ]]
then
echo "Java is not installed"
sudo apt install -y openjdk-8-jre-headless
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
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins=$jenkins_LTS
sudo systemctl start jenkins
sudo ufw allow 8080
else echo "Jenkins is already installed"
fi

# Create admin user
admin_login=$2
admin_password=$3
if [ $# != 3 ]
then
echo "You forgot to enter script parameters (admin login and password)"
exit 1
fi
echo "Admin login will be: $admin_login"
echo "Admin password will be: $admin_password"
test -f $HOME/jenkins-cli.jar
if [ $? == 1 ]
then
wget --retry-connrefused --waitretry=10 --read-timeout=10 --timeout=10 -t 0 -P $HOME http://localhost:8080/jnlpJars/jenkins-cli.jar
fi
temp_pass=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount('$admin_login', '$admin_password')" | java -jar $HOME/jenkins-cli.jar -s "http://localhost:8080" -auth admin:$temp_pass -noKeyAuth groovy = –

# Install Jenkins plugins: Role-Based, Git, Pipeline, BlueOcean, BackUp, SonarQube, Artifactory
java -jar $HOME/jenkins-cli.jar -s "http://localhost:8080/" -auth admin:$temp_pass install-plugin role-strategy git workflow-aggregator blueocean backup sonar artifactory -restart

# Disables the setup wizard & the admin user stuff
java -Djenkins.install.runSetupWizard=false -jar jenkins.war

# Remove jenkins cli
rm $HOME/jenkins-cli.jar
