#!/bin/bash
source /home/ubuntu/.bash_profile
HOSTNAME=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
S3_LOG_FILE=$AIRFLOW_HOME/logs/${HOSTNAME}_s3_install.log
DATESTART=`date`

echo "---------- STARTED AT $DATESTART ----------" >> $S3_LOG_FILE

echo "---------- STARTING COPY FROM S3 ----------" >> $S3_LOG_FILE

if [ "`/home/ubuntu/venv/bin/aws s3 ls s3://$S3_AIRFLOW_BUCKET/dags/`" != "" ];
then
    /home/ubuntu/venv/bin/aws s3 sync s3://$S3_AIRFLOW_BUCKET/dags/ $AIRFLOW_HOME/dags/ --exact-timestamps --delete --quiet --exclude __pycache__
else
    echo "---------- Missing $AIRFLOW_HOME/dags/ ----------" >> $S3_LOG_FILE
    if [ -d "$AIRFLOW_HOME/dags" ]; then
        rm -rf $AIRFLOW_HOME/dags/
        echo "---------- Removed $AIRFLOW_HOME/dags/ ----------" >> $S3_LOG_FILE
    fi
fi

if [ "`/home/ubuntu/venv/bin/aws s3 ls s3://$S3_AIRFLOW_BUCKET/plugins/`" != "" ];
then
    /home/ubuntu/venv/bin/aws s3 sync s3://$S3_AIRFLOW_BUCKET/plugins/ $AIRFLOW_HOME/plugins/ --exact-timestamps --delete --quiet --exclude __pycache__
else
    echo "---------- Missing $AIRFLOW_HOME/plugins/ ----------" >> $S3_LOG_FILE
    if [ -d "$AIRFLOW_HOME/plugins" ]; then
        rm -rf $AIRFLOW_HOME/plugins/
        echo "---------- Removed $AIRFLOW_HOME/plugins/ ----------" >> $S3_LOG_FILE
    fi
fi

if [ "`/home/ubuntu/venv/bin/aws s3 ls s3://$S3_AIRFLOW_BUCKET/sql/`" != "" ];
then
    /home/ubuntu/venv/bin/aws s3 sync s3://$S3_AIRFLOW_BUCKET/sql/ $AIRFLOW_HOME/sql/ --exact-timestamps --delete --quiet --exclude __pycache__
else
    echo "---------- Missing $AIRFLOW_HOME/sql/ ----------" >> $S3_LOG_FILE
    if [ -d "$AIRFLOW_HOME/sql" ]; then
        rm -rf $AIRFLOW_HOME/sql/
        echo "---------- Removed $AIRFLOW_HOME/sql/ ----------" >> $S3_LOG_FILE
    fi
fi

if [ "`/home/ubuntu/venv/bin/aws s3 ls s3://$S3_AIRFLOW_BUCKET/lib/`" != "" ];
then
    /home/ubuntu/venv/bin/aws s3 sync s3://$S3_AIRFLOW_BUCKET/turner_lib/ $AIRFLOW_HOME/turner_lib/ --exact-timestamps --delete --quiet --exclude __pycache__
else
    echo "---------- Missing $AIRFLOW_HOME/turner_lib/ ----------" >> $S3_LOG_FILE
    if [ -d "$AIRFLOW_HOME/turner_lib" ]; then
        rm -rf $AIRFLOW_HOME/turner_lib/
        echo "---------- Removed $AIRFLOW_HOME/turner_lib/ ----------" >> $S3_LOG_FILE
    fi
fi

DATEEND=`date`
echo "---------- FINISHED AT $DATEEND ----------" >> $S3_LOG_FILE
