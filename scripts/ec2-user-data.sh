#!/bin/bash
apt update -y
apt install nginx awscli -y
systemctl enable nginx
systemctl start nginx

# Securely pull decoupled website code from S3 using IAM role
aws s3 cp s3://amit-devops-poc-2026/index.html /var/www/html/index.html
