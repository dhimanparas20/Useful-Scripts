#!/bin/bash

# Start Docker containers with fixed names
sudo docker stop automation
sudo docker rm automation 
sudo docker run -d --network=host --name automation automation
sudo docker stop mongopannel
sudo docker rm mongopannel 
sudo docker run -d --network=host --name mongopannel mongopannel
