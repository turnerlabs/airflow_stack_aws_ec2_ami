#!/usr/bin/bash -x

set -e

curl https://packages.microsoft.com/config/rhel/7/prod.repo >> /home/ec2-user/msprod.repo
sudo cp /home/ec2-user/msprod.repo /etc/yum.repos.d/msprod.repo
rm /home/ec2-user/msprod.repo

sudo yum update -y
sudo ACCEPT_EULA=Y yum install -y msodbcsql17 mssql-tools

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /home/ec2-user/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /home/ec2-user/.bashrc
source /home/ec2-user/.bashrc
echo "------------------- microsoft unixodbc dependencies complete -------------------"

sudo yum install -y gcc unixODBC unixODBC-devel jq python-virtualenv python3-pip mysql-devel python3-devel python3 krb5-devel krb5-workstation cyrus-sasl-devel gdbm-devel java-1.8.0-openjdk postgresql-devel gcc-c++
echo "------------------- airflow yum dependencies complete -------------------"

sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2

echo "export AIRFLOW_HOME=/home/ec2-user/airflow" >> /home/ec2-user/.bash_profile
echo "------------------- append environment variables to bash profile complete -------------------"

wget http://download.redis.io/redis-stable.tar.gz -O /home/ec2-user/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
cd deps
make hiredis jemalloc linenoise lua
cd ..
make
sudo cp src/redis-cli /usr/local/bin/
sudo chmod 755 /usr/local/bin/redis-cli
cd ..
rm -rf redis-stable
echo "------------------- install redis client complete -------------------"

export AIRFLOW_HOME=/home/ec2-user/airflow
export SLUGIFY_USES_TEXT_UNIDECODE=yes

pip3 install --user --upgrade pip
echo "------------------- pip upgrade complete -------------------"

virtualenv -p `which python3` venv
echo "------------------- virtual environment creation complete -------------------"

source ~/venv/bin/activate
echo "------------------- activate virtual environment complete -------------------"

pip install pytest-runner
pip install apache-airflow[all]==1.10.6
pip install awscli==1.16.276
echo "------------------- install airflow complete -------------------"

wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm -O /home/ec2-user/amazon-cloudwatch-agent.rpm

sudo rpm -i /home/ec2-user/amazon-cloudwatch-agent.rpm
echo "------------------- download aws logs -------------------"

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/home/ec2-user/awslogs.json -s
echo "------------------- install aws logs -------------------"

sudo systemctl status amazon-ssm-agent
echo "------------------- start of awslogs complete -------------------"

sudo systemctl enable amazon-ssm-agent

rm /home/ec2-user/amazon-cloudwatch-agent.rpm
echo "------------------- enable autostart of awslogs complete -------------------"

wget https://s3.amazonaws.com/turner-iso-artifacts/AlertLogicAgents/al-agent-LATEST-1.x86_64.rpm -O /home/ec2-user/al-agent_LATEST_amd64.rpm
echo "------------------- download threat manager -------------------"

sudo rpm -i /home/ec2-user/al-agent_LATEST_amd64.rpm
echo "------------------- install threat manager -------------------"

sudo systemctl enable al-agent

rm /home/ec2-user/al-agent_LATEST_amd64.rpm
echo "------------------- enable autostart of threat manager and remove deb-------------------"

chmod 700 /home/ec2-user/s3_install.sh
chmod 700 /home/ec2-user/pip_mod_install.sh
chmod 700 /home/ec2-user/airflow_vars_install.sh

sudo crontab /home/ec2-user/crontab.system
sudo crontab -u ec2-user /home/ec2-user/crontab.airflow
echo "------------------- enable logs cleanup complete -------------------"

sudo cp /home/ec2-user/airflow.sysconfig /etc/profile.d/airflow.sh
sudo cp /home/ec2-user/airflow.conf /usr/lib/tmpfiles.d

sudo cp /home/ec2-user/airflow-webserver.service /lib/systemd/system/airflow-webserver.service
sudo cp /home/ec2-user/airflow-scheduler.service /lib/systemd/system/airflow-scheduler.service

rm /home/ec2-user/airflow.sysconfig
rm /home/ec2-user/airflow.conf

rm /home/ec2-user/airflow-webserver.service
rm /home/ec2-user/airflow-scheduler.service
echo "------------------- copy systemd components complete -------------------"

sudo mkdir /run/airflow
sudo chown ec2-user:ec2-user /run/airflow
echo "------------------- modified pid directory complete -------------------"

mkdir /home/ec2-user/airflow
chown ec2-user:ec2-user /home/ec2-user/airflow

echo "------------------- created airflow directory -------------------"

mkdir /home/ec2-user/airflow/dags
chown ec2-user:ec2-user /home/ec2-user/airflow/dags
mkdir /home/ec2-user/airflow/data
chown ec2-user:ec2-user /home/ec2-user/airflow/data
mkdir /home/ec2-user/airflow/logs
chown ec2-user:ec2-user /home/ec2-user/airflow/logs
mkdir /home/ec2-user/airflow/plugins
chown ec2-user:ec2-user /home/ec2-user/airflow/plugins
mkdir /home/ec2-user/airflow/requirements
chown ec2-user:ec2-user /home/ec2-user/airflow/requirements
mkdir /home/ec2-user/airflow/variables
chown ec2-user:ec2-user /home/ec2-user/airflow/variables

echo "------------------- created common airflow directories complete -------------------"

pip install --upgrade jsonpatch

python --version