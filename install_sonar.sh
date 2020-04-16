#!/bin/bash

# Install Sonar on Centos 7

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

# Install support packages
yum install -y nano wget unzip

# Install the PostgreSQL Repository
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Install the PostgreSQL 10 database Server
yum install -y postgresql10-server postgresql10-contrib

# Initialize the Postgres database
/usr/pgsql-10/bin/postgresql-10-setup initdb

# Change peer to trust and idnet to md5
sed -i 's/local   all             all                                     peer/local   all             all                                     trust/' /var/lib/pgsql/10/data/pg_hba.conf
sed -i 's/host    all             all             127.0.0.1\/32            ident/host    all             all             127.0.0.1\/32            md5/' /var/lib/pgsql/10/data/pg_hba.conf
sed -i 's/host    all             all             ::1\/128                 ident/host    all             all             ::1\/128                 md5/' /var/lib/pgsql/10/data/pg_hba.conf

# Start PostgreSQL Database server
systemctl start postgresql-10

# Enable PostgreSQL Database server to start automatically at System Startup
systemctl enable postgresql-10

# Check status
systemctl status postgresql-10

# Work with PostgreSQL Database server
su - postgres <<EOSU
createuser sonar
psql
ALTER USER sonar WITH ENCRYPTED password 'sonar';
CREATE DATABASE sonarqube OWNER sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;
\q
exit;
EOSU

# Download and Install SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.9.1.zip
unzip sonarqube-7.9.1.zip -d /opt > /dev/null
mv /opt/sonarqube-7.9.1 /opt/sonarqube

# Configure SonarQube
groupadd sonar
useradd -c "user to run SonarQube" -d /opt/sonarqube -g sonar sonar 
echo "sonar" | passwd sonar --stdin
chown -R sonar:sonar /opt/sonarqube
mkdir -p /var/sonarqube/data
mkdir -p /var/sonarqube/temp
chown -R sonar:sonar /var/sonarqube

# Configuration /opt/sonarqube/conf/sonar.properties
sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/' /opt/sonarqube/conf/sonar.properties
sed -i 's/#sonar.jdbc.password=/sonar.jdbc.password=sonar/' /opt/sonarqube/conf/sonar.properties
sed -i 's!#sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube?currentSchema=my_schema!sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube!' /opt/sonarqube/conf/sonar.properties
sed -i 's!#sonar.path.data=data!sonar.path.data=data!' /opt/sonarqube/conf/sonar.properties
sed -i 's!#sonar.path.temp=temp!sonar.path.temp=temp!' /opt/sonarqube/conf/sonar.properties
sed -i 's/#RUN_AS_USER=/RUN_AS_USER=sonar/' /opt/sonarqube/bin/linux-x86-64/sonar.sh

# Configure Systemd service
sh -c 'cat > /etc/systemd/system/sonar.service' <<EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

password=$1
wget -P $HOME https://raw.githubusercontent.com/Orfey95/Install-Jenkins-Sonar-Artifactory/master/post_install_sonar.sh
sed -i "s/replace_password/$password/" $HOME/post_install_sonar.sh
echo "@reboot ${HOME}/post_install_sonar.sh" >> /etc/crontab

# Disable SELinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

# Start Sonar as service
systemctl daemon-reload
systemctl start sonar
systemctl enable sonar
systemctl status sonar

# Increase the limits
echo "vm.max_map_count = 262144" >> /etc/sysctl.conf
echo "fs.file-max = 65536" >> /etc/sysctl.conf
echo "sonar   -   nofile   65536" >> /etc/security/limits.d/99-sonarqube.conf
echo "sonar   -   nproc    2048" >> /etc/security/limits.d/99-sonarqube.conf

# Reboot
reboot

