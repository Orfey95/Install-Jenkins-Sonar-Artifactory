## Install Jenkins on Ubuntu 18.04

Script parameters:
1) Jenkins LTS version. Example: 2.222.1
2) Admin login. Example: sasha
3) Admin password. Example: 1234
4) Sonar IP address. Example: 10.20.30.40
5) Sonar name. Example: my-sonar
6) Artifactory IP address. Example: 40.30.20.10
7) Artifactory name. Example: my-artifactory

Script example:

```
sasha@network:~$ sudo bash install_jenkins.sh 2.222.1 sasha 1234 10.20.30.40 my-sonar 40.30.20.10 my-artifactory
```
List of plugins:
- role-strategy (for role management);
- git (for work with Git);
- workflow-aggregator (for pipeline creation);
- blueocean (for visualization);
- backup (for backup creation);
- sonar (for work with SonarQube);
- artifactory (for work with Artifactory);
- locale (for Jenkins localization);
- maven-plugin (for work with Maven).
## Install Sonar(v7.9.1) with PostgreSQL on CentOS 7
Script example:
```
sasha@network:~$ sudo bash install_sonar.sh
```
## Install Artifactory on CentOS 7
Script parameters:
1) Admin password. Example: 12345678

Script example:
```
sasha@network:~$ sudo bash install_artifactory.sh 12345678
```
