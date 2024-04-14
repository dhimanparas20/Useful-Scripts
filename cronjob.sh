#!/bin/bash

# Start Docker containers with fixed names
sudo docker stop automation
sudo docker rm automation 
sudo docker run -d --network=host --name automation automation

sudo docker stop MongoAdminPannel
sudo docker rm MongoAdminPannel 
sudo docker run -d --network=host --name MongoAdminPannel MongoAdminPannel
