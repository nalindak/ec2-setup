#!/bin/bash

sudo yum update -y
sudo yum install docker git jq -y
sudo usermod -aG docker $USER
sudo service docker start
sudo chmod 666 /var/run/docker.sock