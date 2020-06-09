#!/usr/bin/bash -x

set -e

sudo yum update -y
echo "------------------- package update complete -------------------"

sudo systemctl status amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
echo "------------------- enable autostart of ssm agent complete -------------------"

wget https://s3.amazonaws.com/turner-iso-artifacts/AlertLogicAgents/al-agent-LATEST-1.x86_64.rpm -O /home/ec2-user/al-agent_LATEST_amd64.rpm
echo "------------------- download threat manager -------------------"

sudo rpm -i /home/ec2-user/al-agent_LATEST_amd64.rpm
echo "------------------- install threat manager -------------------"

sudo systemctl enable al-agent

rm /home/ec2-user/al-agent_LATEST_amd64.rpm
echo "------------------- enable autostart of threat manager and remove deb-------------------"