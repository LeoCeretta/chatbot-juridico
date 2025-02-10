#!/bin/bash

sudo yum update -y

sudo yum install -y python3 git
sudo yum install -y python3-pip

cd services
pip install -r requirements.txt

python3 bot_main.py
