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
appname=shipping

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
  
echo -e " ${Y} Proceeding with Java Installation ${N}" 

sudo apt update -y &>> $LOGFILE
sudo apt install unzip &>> $LOGFILE
Validate $? "Installing updates and  unzip"

sudo apt install maven -y &>> $LOGFILE
Validate $? "Installing maven "

cd /app
        if [ $? -eq 0 ]; then
            echo " Directory already exist, so removing the old code"
            sudo rm -rf /app
            Validate $? "Removed Directory"
        fi

 echo " Directory not exists, creating directory and downloading code"

sudo mkdir -p /app
sudo curl -L -o /tmp/$appname.zip https://roboshop-artifacts.s3.amazonaws.com/$appname-v3.zip 
cd /app 
unzip /tmp/$appname.zip
cd /app 
pwd
Validate $? "Created Directory and Downloaded code"


sudo mvn clean package &>> $LOGFILE
Validate $? "Installing dependencies"

sudo mv target/shipping-1.0.jar $appname.jar
Validate $? "Renaming jar file to shipping.jar"

cp $SCRIPT_DIR/$appname.service /etc/systemd/system/$appname.service
Validate $? "Creating Systemctl service"

sudo systemctl daemon-reload
sudo systemctl enable $appname 
sudo systemctl start $appname
Validate $? "Reload and start the shipping service"


echo -e " ${Y} Proceeding with mysql client Installation ${N}"

sudo apt install mysql-client -y
Validate $? "Installing mysqlclient"

sudo mysql -h mysql.manojkoney.store -uroot -pManoj@123 < /app/db/schema.sql
sudo mysql -h mysql.manojkoney.store -uroot -pManoj@123 < /app/db/app-user.sql
sudo mysql -h mysql.manojkoney.store -uroot -pManoj@123 < /app/db/master-data.sql
Validate $? "Uploading schema into mysql db"

sudo systemctl restart $appname
Validate $? "restart the shipping service"





