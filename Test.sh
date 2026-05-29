#!/bin/bash

sudo mkdir -p /var/log/mongodb
LOG_DIR=/var/log/mongodb
sudo chown -R ubuntu:ubuntu $LOG_DIR
sudo chmod -R 755 $LOG_DIR
SCRIPT_NAME=$(basename "$0")
LOGFILE="$LOG_DIR/$SCRIPT_NAME.log"