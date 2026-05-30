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



sudo apt update -y &>> $LOGFILE
sudo apt install rabbitmq-server -y &>> $LOGFILE
sudo apt update -y &>> $LOGFILE
Validate $? "Installing updates and rabbitmq"

sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server
Validate $? "Enabling and starting rabbitmq"


sudo rabbitmqctl add_user roboshop RoboShop@123
sudo rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
Validate $? "Adding roboshop user for rabbitmq"


