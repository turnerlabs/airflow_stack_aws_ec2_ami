#!/usr/bin/bash -x

set -e

sudo add-apt-repository ppa:jonathonf/python-3.6
sudo apt-get update -yq --fix-missing
echo "------------------- apt update complete -------------------"

sudo apt-get -y install unattended-upgrades
echo "------------------- apt upgrade complete -------------------"

curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list >> /home/ubuntu/prod.list
sudo cp /home/ubuntu/prod.list /etc/apt/sources.list.d/mssql-release.list
rm /home/ubuntu/prod.list

sudo apt-get update
sudo ACCEPT_EULA=Y apt-get -y install msodbcsql17 mssql-tools

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /home/ubuntu/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /home/ubuntu/.bashrc
source /home/ubuntu/.bashrc
echo "------------------- microsoft unixodbc dependencies complete -------------------"

sudo apt-get -y install unixodbc unixodbc-dev chrony jq virtualenv python3-pip libmysqlclient-dev python3-dev python3 libkrb5-dev libsasl2-dev mysql-client-core-5.7 python3-gdbm redis-tools openjdk-8-jre
sudo apt-get -y install python3.6-dev python3.6
echo "------------------- airflow aptitude dependencies complete -------------------"

sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1

sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 2

echo "export AIRFLOW_HOME=/home/ubuntu/airflow" >> /home/ubuntu/.bash_profile

echo "------------------- append environment variables to bash profile complete -------------------"

export AIRFLOW_HOME=/home/ubuntu/airflow
export SLUGIFY_USES_TEXT_UNIDECODE=yes

pip3 install --upgrade pip
echo "------------------- pip upgrade complete -------------------"

virtualenv -p `which python3` venv
echo "------------------- virtual environment creation complete -------------------"

source ~/venv/bin/activate
echo "------------------- activate virtual environment complete -------------------"

pip install apache-airflow[all]==1.10.2
pip install botocore==1.12.58
pip install awscli==1.16.68
echo "------------------- install airflow complete -------------------"

sudo sed -i '1 i\server 169.254.169.123 prefer iburst'  /etc/chrony/chrony.conf
echo "------------------- add ip for aws time services -------------------"

sudo /etc/init.d/chrony restart
echo "------------------- start chrony -------------------"

wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /home/ubuntu/amazon-cloudwatch-agent.deb
sudo dpkg -i -E /home/ubuntu/amazon-cloudwatch-agent.deb
echo "------------------- download aws logs -------------------"

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/home/ubuntu/awslogs.json -s
echo "------------------- install aws logs -------------------"

sudo systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent.service
echo "------------------- start of awslogs complete -------------------"

sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
echo "------------------- enable autostart of awslogs complete -------------------"

wget https://s3.amazonaws.com/turner-iso-artifacts/AlertLogicAgents/al-agent_LATEST_amd64.deb -O /home/ubuntu/al-agent_LATEST_amd64.deb
echo "------------------- download threat manager -------------------"

sudo dpkg -i /home/ubuntu/al-agent_LATEST_amd64.deb
echo "------------------- install threat manager -------------------"

sudo systemctl enable al-agent.service

rm /home/ubuntu/al-agent_LATEST_amd64.deb
echo "------------------- enable autostart of threat manager and remove deb-------------------"

chmod 700 /home/ubuntu/pip_mod_install.sh
chmod 700 /home/ubuntu/s3_install.sh

sudo crontab /home/ubuntu/crontab.system
crontab -u ubuntu /home/ubuntu/crontab.airflow
echo "------------------- enable logs cleanup complete -------------------"

sudo cp /home/ubuntu/airflow.sysconfig /etc/profile.d/airflow.sh
sudo cp /home/ubuntu/airflow.conf /usr/lib/tmpfiles.d

sudo cp /home/ubuntu/airflow-worker.service /lib/systemd/system/airflow-worker.service

rm /home/ubuntu/airflow.sysconfig
rm /home/ubuntu/airflow.conf

rm /home/ubuntu/airflow-worker.service
echo "------------------- copy systemd components complete -------------------"

sudo mkdir /run/airflow
sudo chown ubuntu:ubuntu /run/airflow
echo "------------------- modified pid directory complete -------------------"

mkdir /home/ubuntu/airflow
chown ubuntu:ubuntu /home/ubuntu/airflow

echo "------------------- created airflow directory -------------------"

mkdir /home/ubuntu/airflow/dags
chown ubuntu:ubuntu /home/ubuntu/airflow/dags
mkdir /home/ubuntu/airflow/data
chown ubuntu:ubuntu /home/ubuntu/airflow/data
mkdir /home/ubuntu/airflow/logs
chown ubuntu:ubuntu /home/ubuntu/airflow/logs
mkdir /home/ubuntu/airflow/plugins
chown ubuntu:ubuntu /home/ubuntu/airflow/plugins
mkdir /home/ubuntu/airflow/requirements
chown ubuntu:ubuntu /home/ubuntu/airflow/requirements
mkdir /home/ubuntu/airflow/variables
chown ubuntu:ubuntu /home/ubuntu/airflow/variables

echo "------------------- created common airflow directories complete -------------------"

pip install --upgrade jsonpatch

cd /home/ubuntu
wget https://launchpad.net/cloud-init/trunk/18.2/+download/cloud-init-18.2.tar.gz
tar -zxvf /home/ubuntu/cloud-init-18.2.tar.gz
cd /home/ubuntu/cloud-init-18.2/
python setup.py build
python setup.py install --init-system systemd
sudo cp /home/ubuntu/venv/bin/cloud-init /usr/bin/cloud-init
echo "------------------- cloud init fix -------------------"