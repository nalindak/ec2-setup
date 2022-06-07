#!/bin/bash

mv ~/.bashrc ~/.bashrc_original
curl https://raw.githubusercontent.com/nalindak/ec2-setup/main/.bashrc > ~/.bashrc
source ~/.bashrc

sudo yum update -y
sudo yum install docker git jq -y
sudo usermod -aG docker $USER
sudo service docker start
sudo chmod 666 /var/run/docker.sock