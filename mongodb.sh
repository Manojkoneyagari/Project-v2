#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"



sudo mkdir -p /var/log/mongodb
LOG_DIR=/var/log/mongodb
sudo chown -R ubuntu:ubuntu $LOG_DIR
sudo chmod -R 755 $LOG_DIR
SCRIPT_NAME=$(basename "$0")
echo -e "${Y}....$SCRIPT_NAME {N}"
LOGFILE="$LOG_DIR/${SCRIPT_NAME}.log"


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




#Import key
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg &>> $LOGFILE
Validate $? "Adding mongodb gpg keys"

#adding repo
echo "deb [ arch=amd64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list &>> $LOGFILE
Validate $? "Adding repository"

sudo apt update -y
sudo apt install -y mongodb-org &>> $LOGFILE
Validate $? "Updating and installing mongodb application"

sudo systemctl enable mongod
sudo systemctl start mongod
Validate $? "Starting and enabling the mongodb service"

sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
Validate $? "Changes in systemdfile to allow all traffic"

sudo systemctl restart mongod
Validate $? "Restarting systemd service"
