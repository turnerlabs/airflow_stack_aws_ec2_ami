#!/usr/bin/bash -x

set -e

sudo apt-get update -yq --fix-missing
echo "------------------- apt update complete -------------------"

sudo apt-get -y install unattended-upgrades chrony

sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
echo "------------------- apt upgrade complete -------------------"

sudo sed -i '1 i\server 169.254.169.123 prefer iburst'  /etc/chrony/chrony.conf
echo "------------------- add ip for aws time services -------------------"

sudo /etc/init.d/chrony restart
echo "------------------- start chrony -------------------"

wget https://s3.amazonaws.com/turner-iso-artifacts/AlertLogicAgents/al-agent_LATEST_amd64.deb -O /home/ubuntu/al-agent_LATEST_amd64.deb
echo "------------------- download threat manager -------------------"

sudo dpkg -i /home/ubuntu/al-agent_LATEST_amd64.deb
echo "------------------- install threat manager -------------------"

sudo systemctl enable al-agent.service

rm /home/ubuntu/al-agent_LATEST_amd64.deb
echo "------------------- enable autostart of threat manager and remove deb-------------------"