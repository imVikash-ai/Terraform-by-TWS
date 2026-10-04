#/bin/bash

sudo apt-get update
sudo apt-get install nginx -y
sudo syatemctl start nginx
sudo systemctl enable nginx


