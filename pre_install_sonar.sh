#!/bin/bash

# PREInstall Sonar on Centos 7

# Turn on logging
set -x

# Increase the limits
echo "vm.max_map_count = 262144" >> /etc/sysctl.conf
echo "fs.file-max = 65536" >> /etc/sysctl.conf
echo "sonar   -   nofile   65536" >> /etc/security/limits.d/99-sonarqube.conf
echo "sonar   -   nproc    2048" >> /etc/security/limits.d/99-sonarqube.conf


# Reboot
reboot
