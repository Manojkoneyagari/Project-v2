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
sudo apt install unzip -y &>> $LOGFILE
Validate $? "Installing updates and unzip installation"

curl https://nginx.org/keys/nginx_signing.key | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg &>> $LOGFILE
Validate $? "Adding nginx keys"


echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | \
sudo tee /etc/apt/sources.list.d/nginx.list
Validate $? "Adding nginx repo"


sudo apt update -y &>> $LOGFILE
sudo apt install -y nginx=1.24.* &>> $LOGFILE
Validate $? "Installing nginx 1.24 version"


sudo rm -rf /var/www/html/*
Validate $? "sRemoving default html webpage"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
cd /var/www/html
sudo unzip /tmp/frontend.zip
Validate $? "Downloading default html webpage"


cp $SCRIPT_DIR/nginx.conf /etc/nginx/sites-available/roboshop
Validate $? "Creating new config file instead of disturbing the original config"

sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/roboshop.conf /etc/nginx/sites-enabled/roboshop
Validate $? "removing default link, relinking for our config file"

sudo systemctl restart nginx
Validate $? "restarting nginx"

