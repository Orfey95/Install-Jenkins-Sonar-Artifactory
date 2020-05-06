#!/bin/bash

# POSTInstall Sonar on Centos 7

# Variables
HTTP_CODE_204=204

#Firewall on
iptables -A INPUT -p tcp -s localhost --dport 9000 -j ACCEPT
iptables -A INPUT -p tcp --dport 9000 -j DROP

echo "Firewall ON" >> /var/log/temp_sonar.log

# API change admin password
while [[ "$(curl -s -o /dev/null -w ''%"{http_code}"'' -u admin:admin -X POST http://localhost:9000/api/users/change_password --data 'login=admin&password=replace_password&previousPassword=admin')" != "$HTTP_CODE_204" ]]; do 
	sleep 5; 
done

echo "Password changed successful!!" >> /var/log/temp_sonar.log

#Firewall off
iptables -D INPUT -p tcp -s localhost --dport 9000 -j ACCEPT
iptables -D INPUT -p tcp --dport 9000 -j DROP

echo "Firewall OFF" >> /var/log/temp_sonar.log

sed -i "s!@reboot root sleep 30 && ${HOME}/post_install_sonar.sh 2>&1!!" /etc/crontab

rm "$0"
