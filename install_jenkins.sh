#!/bin/bash

# Install Jenkins in Ubuntu 18.04

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
-restart

# Remove jenkins cli
rm $HOME/jenkins-cli.jar

# Sonar integration
echo "<?xml version='1.1' encoding='UTF-8'?>
<hudson.plugins.sonar.SonarGlobalConfiguration plugin="sonar@2.11">
  <jenkinsSupplier class="hudson.plugins.sonar.SonarGlobalConfiguration$$Lambda$106/1934640915"/>
  <installations>
    <hudson.plugins.sonar.SonarInstallation>
      <name>my-sonar</name>
      <serverUrl>http://10.10.10.42:9000</serverUrl>
      <credentialsId></credentialsId>
      <webhookSecretId></webhookSecretId>
      <mojoVersion></mojoVersion>
      <additionalProperties></additionalProperties>
      <additionalAnalysisProperties></additionalAnalysisProperties>
      <triggers>
        <skipScmCause>false</skipScmCause>
        <skipUpstreamCause>false</skipUpstreamCause>
        <envVar></envVar>
      </triggers>
    </hudson.plugins.sonar.SonarInstallation>
  </installations>
  <buildWrapperEnabled>false</buildWrapperEnabled>
  <dataMigrated>true</dataMigrated>
  <credentialsMigrated>true</credentialsMigrated>
</hudson.plugins.sonar.SonarGlobalConfiguration>" > /var/lib/jenkins/hudson.plugins.sonar.SonarGlobalConfiguration.xml
echo "<?xml version='1.1' encoding='UTF-8'?>
<hudson.plugins.sonar.SonarRunnerInstallation_-DescriptorImpl plugin="sonar@2.11">
  <installations>
    <hudson.plugins.sonar.SonarRunnerInstallation>
      <name>my-sonar</name>
      <properties>
        <hudson.tools.InstallSourceProperty>
          <installers>
            <hudson.plugins.sonar.SonarRunnerInstaller>
              <id>4.3.0.2102</id>
            </hudson.plugins.sonar.SonarRunnerInstaller>
          </installers>
        </hudson.tools.InstallSourceProperty>
      </properties>
    </hudson.plugins.sonar.SonarRunnerInstallation>
  </installations>
</hudson.plugins.sonar.SonarRunnerInstallation_-DescriptorImpl>" > /var/lib/jenkins/hudson.plugins.sonar.SonarRunnerInstallation.xml
