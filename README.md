# What is this?

**Currently supported version of Airflow: 1.10.11(AWS Linux Only)**

**The last supported release of the Ubuntu version of Airflow was 1.10.6 due to the following: https://launchpad.net/~jonathonf**

**I will remove the Ubuntu version of this sometime in February**

This contains the packer code to create the AMI's for the Bastion, Webserver / Scheduler(combined) and the Worker for Airflow.

The airflow_websched path contains the code to generate a python 3.x(latest on Ubuntu 16.04 or AWS Linux) AMI of an airflow webserver and scheduler that works with Airflow.

The airflow_worker path contains the code to generate a python 3.x(latest on Ubuntu 16.04 or AWS Linux) AMI of an airflow worker that works with Airflow.

Each directory contains code for both ubuntu and the amazon linux ami.

The airflow AMI's also have the following additions / assumptions:

- AIRFLOW_HOME is /home/ubuntu/airflow(ubuntu) , /home/ec2-user/airflow(aws linux)
- Python version is 3.6.7(ubuntu), 3.7.6(aws linux)
- Python uses a virtual environment that can be activated by `source ~/venv/bin/activate`
- Task logs will be sent to S3 bucket using settings in Airflow config
- Airflow logs are being pushed to cloudwatch logs for easier viewing as well
- The logs are being zipped every hour(and removed every 24 hours) via crontab using logrotate.
- The services are using systemd services so you can stop and start the 3 services as follows:
  - `systemctl stop airflow-webserver`
  - `systemctl stop airflow-scheduler`
  - `systemctl stop airflow-worker`
