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
sudo yum install -y nano wget

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

# Change the password for the default PostgreSQL user
echo "123" | sudo passwd postgres --stdin

# Switch to the postgres user
sudo su - postgres

# Create the sonar user
createuser sonar

# Switch to the PostgreSQL shell
psql

# Set a password for the newly created user for SonarQube database
ALTER USER sonar WITH ENCRYPTED password 'sonar';

# Create a new database for PostgreSQL database by running
CREATE DATABASE sonarqube OWNER sonar;

# Grant all privileges to sonar user on sonarqube Database
grant all privileges on sonarqube  to sonar;

# Exit from the psql shell and switch back to the sudo user
\q
exit
