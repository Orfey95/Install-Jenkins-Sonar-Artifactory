#!/bin/bash
# Install Sonar in Centos 7

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

# Install support packages
sudo yum install -y nano wget unzip

# Install the PostgreSQL Repository
sudo yum install -y https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm

# Install the PostgreSQL 10 database Server
sudo yum install -y postgresql10-server postgresql10-contrib

# Initialize the Postgres database
sudo /usr/pgsql-10/bin/postgresql-10-setup initdb

# Change peer to trust and idnet to md5
sudo sed -i 's/local   all             all                                     peer/local   all             all                                     trust/' /var/lib/pgsql/10/data/pg_hba.conf
sudo sed -i 's/host    all             all             127.0.0.1\/32            ident/host    all             all             127.0.0.1\/32            md5/' /var/lib/pgsql/10/data/pg_hba.conf
sudo sed -i 's/host    all             all             ::1\/128                 ident/host    all             all             ::1\/128                 md5/' /var/lib/pgsql/10/data/pg_hba.conf

# Start PostgreSQL Database server
sudo systemctl start postgresql-10

# Enable PostgreSQL Database server to start automatically at System Startup
sudo systemctl enable postgresql-10

# Work with PostgreSQL Database server
sudo su postgres <<EOSU
createuser sonar
psql
ALTER USER sonar WITH ENCRYPTED password 'sonar';
CREATE DATABASE sonarqube OWNER sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;
\q
exit;
EOSU

# Download and Install SonarQube
cd /tmp
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.9.1.zip
sudo unzip sonarqube-7.9.1.zip -d /opt
sudo mv /opt/sonarqube-7.9.1 /opt/sonarqube

# Configure SonarQube
sudo groupadd sonar
sudo useradd -c "user to run SonarQube" -d /opt/sonarqube -g sonar sonar 
echo "1234" | sudo passwd sonar --stdin
sudo chown -R sonar:sonar /opt/sonarqube
sudo sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/#sonar.jdbc.password=/sonar.jdbc.password=1234/' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/#RUN_AS_USER=/RUN_AS_USER=sonar/' /opt/sonarqube/bin/linux-x86-64/sonar.sh
sudo su sonar <<EOSU
cd /opt/sonar/bin/linux-x86-64/
./sonar.sh start
exit;
EOSU
