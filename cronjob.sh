#!/bin/bash

# Start Docker containers with fixed names
docker stop mongoadminpannel 
docker rm mongoadminpannel 
docker run -d --network=host --name mongoadminpannel mongoadminpannel 
doker stop automation 
docker rm automation 
docker run -d --network=host --name automation automation
