#!/bin/bash
set -e
sudo yum update -y
sudo yum install -y httpd
sudo /sbin/chkconfig httpd on
ls -l /var/tmp/content
sudo cp /var/tmp/content/*  /var/www/html/.
