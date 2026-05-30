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
appname=cart

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
sudo apt install mysql-server -y &>> $LOGFILE
Validate $? "Installing updates and mysql server"


sudo systemctl enable mysql 
sudo systemctl start mysql
Validate $? "Starting and enabling mysql service"

sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Manoj@123';"
sudo mysql -e "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'Manoj@123';"
sudo mysql -e " GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;" 
sudo mysql -e "FLUSH PRIVILEGES;"
Validate $? "Executing sql commands to create root with all permissions"


sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
Validate $? "Changing mysql config to allow all traffic"

sudo systemctl restart mysql
Validate $? "Restarting mysql service"
