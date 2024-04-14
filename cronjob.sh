#!/bin/bash

# Start Docker containers with fixed names
sudo docker stop automation
sudo docker rm automation 
sudo docker run -d --network=host --name automation automation

sudo docker stop mongo_admin_pannel
sudo docker rm mongo_admin_pannel 
sudo docker run -d --network=host --name mongo_admin_pannel mongo_admin_pannel
