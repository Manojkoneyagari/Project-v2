#!/bin/bash

sudo mkdir -p /var/log/mongodb
LOG_DIR=/var/log/mongodb
echo " $? Directory created succesfully"
sudo chown -R ubuntu:ubuntu $LOG_DIR
sudo chmod -R 755 $LOG_DIR
echo " $? Permissions succesfully"
echo $0
SCRIPT_NAME=$(basename "$0")
echo "$SCRIPT_NAME"
LOGFILE="$LOG_DIR/$SCRIPT_NAME.log"