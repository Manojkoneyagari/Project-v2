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
sudo apt install curl gnupg apt-transport-https -y &>> $LOGFILE
Validate $? "Installing updates"


curl -1sLf 'https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA' \
| sudo gpg --dearmor -o /usr/share/keyrings/com.rabbitmq.team.gpg
curl -1sLf 'https://keys.openpgp.org/vks/v1/by-fingerprint/9F4587F226208342F0AD1D45ABF5BD827BD9BF62' \
| sudo gpg --dearmor -o /usr/share/keyrings/net.launchpad.ppa.rabbitmq.erlang.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/gpg.key' \
| sudo gpg --dearmor -o /usr/share/keyrings/io.cloudsmith.rabbitmq.gpg
Validate $? "Adding keys for repo"


cat <<EOF | sudo tee /etc/apt/sources.list.d/rabbitmq.list
deb [signed-by=/usr/share/keyrings/net.launchpad.ppa.rabbitmq.erlang.gpg] https://ppa1.novemberain.com/erlang/ubuntu jammy main
deb-src [signed-by=/usr/share/keyrings/net.launchpad.ppa.rabbitmq.erlang.gpg] https://ppa1.novemberain.com/erlang/ubuntu jammy main

deb [signed-by=/usr/share/keyrings/io.cloudsmith.rabbitmq.gpg] https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/deb/ubuntu jammy main
deb-src [signed-by=/usr/share/keyrings/io.cloudsmith.rabbitmq.gpg] https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/deb/ubuntu jammy main
EOF
Validate $? "Adding repo"


sudo apt update -y &>> $LOGFILE
sudo apt install erlang-base erlang-asn1 erlang-crypto erlang-eldap \
erlang-ftp erlang-inets erlang-mnesia erlang-os-mon erlang-parsetools \
erlang-public-key erlang-runtime-tools erlang-snmp erlang-ssl \
erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl rabbitmq-server -y
Validate $? "Install erlang and rabbitmq"


sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server
Validate $? "Enabling and starting rabbitmq"


sudo rabbitmqctl add_user roboshop RoboShop@123
sudo rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
Validate $? "Adding roboshop user for rabbitmq"


