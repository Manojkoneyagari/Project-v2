#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"



sudo mkdir -p /var/log/roboshop
LOG_DIR=/var/log/roboshop
sudo chown -R ubuntu:ubuntu $LOG_DIR
sudo chmod -R 755 $LOG_DIR
SCRIPT_NAME=$(basename "$0")
echo -e "${Y}....$SCRIPT_NAME ${N}"
LOGFILE="$LOG_DIR/${SCRIPT_NAME}.log"
SCRIPT_DIR=$PWD

USERID=$(id -u)
Timestamp=$(date "+%Y-%m-%d %H:%M:%S")


    if [ $USERID -ne 0 ]; then
        echo " Please run the script with root user or sudo access" | tee -a $LOGFILE
        exit 1;
    fi


    Validate(){
        if [ $1 -eq 0 ]; then
            echo -e "$Timestamp [ Info ] $2 ... ${G} success ${N}" | tee -a $LOGFILE
        else
            echo -e "$Timestamp [ Error ] $2 ... ${R} failed ${N}" | tee -a $LOGFILE
        fi
    }




id roboshop &>> $LOGFILE
    if [ $? -eq 0 ]; then
       echo " roboshop user already created "
    else
       echo " Creating roboshop user "
      sudo useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
      Validate $? "Adding System user roboshop"
    fi
  
sudo apt update -y &>> $LOGFILE
sudo apt install -y lsb-release curl gpg &>> $LOGFILE
Validate $? "Installing updates"


curl -fsSL https://packages.redis.io/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg &>> $LOGFILE
Validate $? "Adding keys"

echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/redis.list &>> $LOGFILE
Validate $? "Adding repo"

sudo apt update -y &>> $LOGFILE
sudo apt install -y redis &>> $LOGFILE
Validate $? "Installing redis"

sudo sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
Validate $? "Changes in systemdfile to allow all traffic and protected no" 

sudo systemctl enable redis-server
sudo systemctl start redis-server
Validate $? "Starting and enabling redis"
