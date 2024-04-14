#The script must be run uisng sudo
# The script installs the following packages: Nginx,MongoDB,MosquittoMQTT,Docker,neofetch,ngrok,git,snapd,ufw
#The script also setups some of configs wherever needed
# HOW to rin ?
# wget https://raw.githubusercontent.com/dhimanparas20/Bash-Scripts/main/AIO_PI-OS_ServerSetup.sh && chmod +x AIO_PI-OS_ServerSetup.sh && time sudo ./AIO_PI-OS_ServerSetup.sh


#Start
clear
#!/bin/bash

# Enable immediate exit on error
set -e

# Check if the script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script with sudo:"
    echo "sudo ./ok.sh"
    exit 1
fi

#The Basics
apt update
apt upgrade -y
apt install git snapd python3 python3-pip nginx mosquitto mosquitto-clients ufw neofetch lolcat -y
#install ngrok
snap install ngrok
clear
neofetch
sleep 2

#Install Docker
clear
curl -sSL https://get.docker.com | sh
echo "---------------------------------------------------------------------------------"
echo "                                  Installed Docker                               "
echo "---------------------------------------------------------------------------------"
sleep 2

# Allow installing pip modules globally
set +e
sudo mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old
set -e

#Docker compose
clear
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo "---------------------------------------------------------------------------------"
echo "                             Installed Docker Compose                            "
echo "---------------------------------------------------------------------------------"
sleep 2

#Store git passwords and add user signature
clear
git config --global user.name "dhimanparas20"
git config --global user.email "dhimanparas20@gmail.com"
git config --global credential.helper cache
git config --global credential.helper store
echo "---------------------------------------------------------------------------------"
echo "                                  Added Git Configs                              "
echo "---------------------------------------------------------------------------------"
sleep 2

#installing MongoDB
clear
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - 
echo "deb [ arch=arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt-get update --allow-insecure-repositories
apt-get install -y mongodb-org=4.4.1  mongodb-org-server=4.4.1  mongodb-org-shell=4.4.1 mongodb-org-mongos=4.4.1 mongodb-org-tools=4.4.1 
echo "mongodb-org hold" | dpkg --set-selections &&
echo "mongodb-org-server hold" | dpkg --set-selections &&
echo "mongodb-org-shell hold" | dpkg --set-selections &&
echo "mongodb-org-mongos hold" | dpkg --set-selections &&
echo "mongodb-org-tools hold" | dpkg --set-selections
echo "---------------------------------------------------------------------------------"
echo "                                  Installed MongoDB                              "
echo "---------------------------------------------------------------------------------"
sleep 2

#Start and enable all services
clear
systemctl start docker && systemctl enable docker
systemctl start mongod && systemctl enable mongod
systemctl start nginx && systemctl enable nginx
systemctl start mosquitto && systemctl enable mosquitto
echo "---------------------------------------------------------------------------------"
echo "                         All Services Started & Enabled                          "
echo "---------------------------------------------------------------------------------"
sleep 2

#Edit Mosquitto Config File
clear
echo "allow_anonymous false" >> /etc/mosquitto/mosquitto.conf
echo "password_file /etc/mosquitto/passwd" >> /etc/mosquitto/mosquitto.conf
echo "listener 1883 0.0.0.0" >> /etc/mosquitto/conf.d/protocols.conf
echo "protocol mqtt" >> /etc/mosquitto/conf.d/protocols.conf
echo "listener 1884 0.0.0.0" >> /etc/mosquitto/conf.d/protocols.conf
echo "protocol websockets" >> /etc/mosquitto/conf.d/protocols.conf
mosquitto_passwd -c /etc/mosquitto/passwd mst <<< "2069" #Creates and setup mosquitto password
ufw allow 1883/tcp
ufw allow 1884/tcp
echo "---------------------------------------------------------------------------------"
echo "                      M0squitto MQTT configs Done                                "
echo "---------------------------------------------------------------------------------"
sleep 2
#mosquitto_passwd -c /etc/mosquitto/passwd mst

#Downloading of desired scripts
clear
mkdir Downloads 
wget -P $(pwd)/Downloads/ https://raw.githubusercontent.com/dhimanparas20/Bash-Scripts/main/NginxPIServer.conf https://raw.githubusercontent.com/dhimanparas20/Bash-Scripts/main/cronjob.sh
cd $(pwd)/Downloads/ && chmod +x cronjob.sh
echo "---------------------------------------------------------------------------------"
echo "                          Scripts downloaded to /home/Downloads                  "
echo "---------------------------------------------------------------------------------"
sleep 2

#Setting up Nginx
clear
cp $(pwd)/Downloads/NginxPIServer.conf /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/NginxPIServer.conf /etc/nginx/sites-enabled/
nginx -t
echo "---------------------------------------------------------------------------------"
echo "                                  NGINX Setup Done                               "
echo "---------------------------------------------------------------------------------"
sleep 2

#Finally Restarting all the service
clear
systemctl restart docker && systemctl status docker --no-pager
systemctl restart mongod && systemctl status mongod --no-pager
systemctl restart nginx && systemctl status nginx --no-pager
systemctl restart mosquitto && systemctl status mosquitto --no-pager
echo "---------------------------------------------------------------------------------"
echo "                          All services Restarted                                 "
echo "---------------------------------------------------------------------------------"
sleep 2

#clone and run Mongo Admin Pannel
clear
cd
git clone https://github.com/dhimanparas20/Mongo-Admin-Pannel.git MongoAdminPannel
cd MongoAdminPannel && docker build -t mongo_admin_pannel .
docker run -d --network=host --name mongo_admin_pannel mongo_admin_pannel
cd
echo "---------------------------------------------------------------------------------"
echo "                   Deployed Mongo Admin PAnnel on port 5500                      "
echo "---------------------------------------------------------------------------------"
sleep 2

#Writing a cron file
clear
export EDITOR=nano
temp_cron=$(mktemp)
echo "@reboot $(pwd)/Downloads/cronjob.sh" >> "$temp_cron"
crontab "$temp_cron"
rm "$temp_cron"
echo "Cron job added successfully."
echo "---------------------------------------------------------------------------------"
echo "                              Cron JOb Added                                     "
echo "---------------------------------------------------------------------------------"
sleep 2

#Done
clear
echo "---------------------------------------------------------------------------------"
echo "                                     DONE :-)                                    "
echo "---------------------------------------------------------------------------------"
clear
cd
git clone https://github.com/dhimanparas20/MST-Automations.git
cd MST-Automations && docker build -t automation .
docker run -d --network=host --name automation automation
cd
echo "---------------------------------------------------------------------------------"
echo "                         Deployed Room Automation                                "
echo "---------------------------------------------------------------------------------"
