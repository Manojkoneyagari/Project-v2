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
  

#sudo useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop


echo -e " ${Y} Proceeding with Nodejs Installation ${N}"
#adding repo
    sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &>> $LOGFILE
    Validate $? "Adding Nodejs repository"

    sudo apt update -y &>> $LOGFILE
    sudo apt install -y nodejs &>> $LOGFILE
    sudo apt install unzip -y &>> $LOGFILE
    Validate $? "Updating and installing nodejs application and unzip"

    sudo mkdir /app
    sudo curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
    cd /app 
    sudo unzip /tmp/catalogue.zip
    sudo npm install &>> $LOGFILE
    Validate $? "Downloading code and installing dependencies"

    cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
    Validate $? "Creating Systemctl service"

   

echo -e " ${Y} Proceeding with Mongodb Installation ${N}"
     
    sudo curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
    sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
    --dearmor &>> $LOGFILE
    Validate $? "Adding mongodb gpg keys"

    
    echo "deb [ arch=amd64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
    sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list &>> $LOGFILE
    Validate $? "Adding repository"

    sudo apt install -y mongodb-mongosh
    Validate $? "Installing mongodb client"


    mongosh --host mongodb.manojkoney.store </app/db/master-data.js
    Validate $? "Uploading schema into mongodb"



    sudo systemctl daemon-reload
    sudo systemctl enable catalogue 
    sudo systemctl start catalogue
    Validate $? "Reload and start the catalogue service"




