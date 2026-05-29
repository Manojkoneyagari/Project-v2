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
appname=user

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
  

#sudo useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop


echo -e " ${Y} Proceeding with Nodejs Installation ${N}"
#adding repo
    sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &>> $LOGFILE
    Validate $? "Adding Nodejs repository"

    sudo apt update -y &>> $LOGFILE
    sudo apt install -y nodejs &>> $LOGFILE
    sudo apt install unzip -y &>> $LOGFILE
    Validate $? "Updating and installing nodejs application and unzip"

    cd /app
        if [ $? -eq 0 ]; then
            echo " Directory already exist, so removing the old code"
            sudo rm -rf /app
            Validate $? "Removed Directory"
        fi

    echo " Directory not exists, creating directory and downloading code"
    sudo mkdir /app
    sudo curl -o /tmp/$appname.zip https://roboshop-artifacts.s3.amazonaws.com/$appname-v3.zip 
    cd /app 
    sudo unzip /tmp/$appname.zip
    Validate $? "Created Directory and Downloaded code"
    
    sudo npm install &>> $LOGFILE
    Validate $? "Installing dependencies"

    cp $SCRIPT_DIR/$appname.service /etc/systemd/system/$appname.service
    Validate $? "Creating Systemctl service"

    sudo systemctl daemon-reload
    sudo systemctl enable $appname 
    sudo systemctl start $appname
    Validate $? "Reload and start the user service"