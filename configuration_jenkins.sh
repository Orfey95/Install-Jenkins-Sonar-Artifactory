#!/bin/bash

# Configuration Jenkins

# Turn on logging
set -x

#Variables
jenkins_LTS=$1
sonar_ip=$2
sonar_name=$3
artifactory_ip=$4

####################################### config.xml ################################################
echo "<?xml version='1.1' encoding='UTF-8'?>
<hudson>
  <disabledAdministrativeMonitors/>
  <version>$jenkins_LTS</version>
  <installStateName>NEW</installStateName>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <useSecurity>true</useSecurity>
  <authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy">
    <denyAnonymousReadAccess>true</denyAnonymousReadAccess>
  </authorizationStrategy>
  <securityRealm class="hudson.security.HudsonPrivateSecurityRealm">
    <disableSignup>true</disableSignup>
    <enableCaptcha>false</enableCaptcha>
  </securityRealm>
  <disableRememberMe>false</disableRememberMe>
  <projectNamingStrategy class="jenkins.model.ProjectNamingStrategy$DefaultProjectNamingStrategy"/>
  <workspaceDir>${JENKINS_HOME}/workspace/${ITEM_FULL_NAME}</workspaceDir>
  <buildsDir>${ITEM_ROOTDIR}/builds</buildsDir>
  <jdks/>
  <viewsTabBar class="hudson.views.DefaultViewsTabBar"/>
  <myViewsTabBar class="hudson.views.DefaultMyViewsTabBar"/>
  <clouds/>
  <quietPeriod>5</quietPeriod>
  <scmCheckoutRetryCount>0</scmCheckoutRetryCount>
  <views>
    <hudson.model.AllView>
      <owner class="hudson" reference="../../.."/>
      <name>all</name>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
      <properties class="hudson.model.View$PropertyList"/>
    </hudson.model.AllView>
  </views>
  <primaryView>all</primaryView>
  <slaveAgentPort>-1</slaveAgentPort>
  <label></label>
  <crumbIssuer class="hudson.security.csrf.DefaultCrumbIssuer">
    <excludeClientIPFromCrumb>false</excludeClientIPFromCrumb>
  </crumbIssuer>
  <nodeProperties/>
  <globalNodeProperties/>
</hudson>" > /var/lib/jenkins/config.xml

###################################### hudson.plugins.sonar.SonarGlobalConfiguration.xml ##################
echo "<?xml version='1.1' encoding='UTF-8'?>
<hudson.plugins.sonar.SonarGlobalConfiguration plugin="sonar@2.11">
  <jenkinsSupplier class="hudson.plugins.sonar.SonarGlobalConfiguration$$Lambda$90/492572393"/>
  <installations>
    <hudson.plugins.sonar.SonarInstallation>
      <name>$sonar_name</name>
      <serverUrl>https://$sonar_ip:9000</serverUrl>
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

##################################### hudson.plugins.sonar.SonarRunnerInstallation.xml #############
echo "<?xml version='1.1' encoding='UTF-8'?>
<hudson.plugins.sonar.SonarRunnerInstallation_-DescriptorImpl plugin="sonar@2.11">
  <installations>
    <hudson.plugins.sonar.SonarRunnerInstallation>
      <name>$sonar_name</name>
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

#################################### org.jfrog.hudson.ArtifactoryBuilder.xml #############################
echo "<?xml version='1.1' encoding='UTF-8'?>
<org.jfrog.hudson.ArtifactoryBuilder_-DescriptorImpl plugin="artifactory@3.6.1">
  <useCredentialsPlugin>true</useCredentialsPlugin>
  <artifactoryServers>
    <org.jfrog.hudson.ArtifactoryServer>
      <url>https://1.2.3.4:8081</url>
      <id>my_artifactory</id>
      <timeout>300</timeout>
      <bypassProxy>false</bypassProxy>
      <connectionRetry>3</connectionRetry>
      <deploymentThreads>3</deploymentThreads>      
    </org.jfrog.hudson.ArtifactoryServer>
  </artifactoryServers>
</org.jfrog.hudson.ArtifactoryBuilder_-DescriptorImpl>" > /var/lib/jenkins/org.jfrog.hudson.ArtifactoryBuilder.xml

# Change owner
chown -R jenkins:jenkins /var/lib/jenkins

# Restart Jenkins
systemctl restart Jenkins
