#The script must be run uisng sudo
# The script installs the following packages: Nginx,MongoDB,MosquittoMQTT,Docker,neofetch,ngrok,git,snapd,ufw
#The script also setups some of configs wherever needed

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
apt install git snapd python3 python3-pip nginx mosquitto mosquitto-clients ufw neofetch -y
#install ngrok
snap install ngrok
clear
neofetch

#Install Docker
curl -sSL https://get.docker.com | sh

# Allow installing pip modules globally
set +e
sudo mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old
set -e

#Docker compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#Store git passwords and add user signature
git config --global user.name "dhimanparas20"
git config --global user.email "dhimanparas20@gmail.com"
git config --global credential.helper cache
git config --global credential.helper store

#installing MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - 
echo "deb [ arch=arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt-get update --allow-insecure-repositories
apt-get install -y mongodb-org=4.4.1  mongodb-org-server=4.4.1  mongodb-org-shell=4.4.1 mongodb-org-mongos=4.4.1 mongodb-org-tools=4.4.1 
echo "mongodb-org hold" | dpkg --set-selections &&
echo "mongodb-org-server hold" | dpkg --set-selections &&
echo "mongodb-org-shell hold" | dpkg --set-selections &&
echo "mongodb-org-mongos hold" | dpkg --set-selections &&
echo "mongodb-org-tools hold" | dpkg --set-selections

#Start and enable all services
systemctl start docker && systemctl enable docker
systemctl start mongod && systemctl enable mongod
systemctl start nginx && systemctl enable nginx
systemctl start mosquitto && systemctl enable mosquitto

#Edit Mosquitto Config File
echo "allow_anonymous false" >> /etc/mosquitto/mosquitto.conf
echo "password_file /etc/mosquitto/passwd" >> /etc/mosquitto/mosquitto.conf
echo "listener 1883 0.0.0.0" >> /etc/mosquitto/conf.d/protocols.conf
echo "protocol mqtt" >> /etc/mosquitto/conf.d/protocols.conf
echo "listener 1884 0.0.0.0" >> /etc/mosquitto/conf.d/protocols.conf
echo "protocol websockets" >> /etc/mosquitto/conf.d/protocols.conf
echo -e "2069\n2069" | mosquitto_passwd -c /etc/mosquitto/passwd mst  #Creates and setup mosquitto password
ufw allow 1883/tcp
ufw allow 1884/tcp
#mosquitto_passwd -c /etc/mosquitto/passwd mst

#Downloading of desired scripts
mkdir Downloads 
wget -P $(pwd)/Downloads/ https://raw.githubusercontent.com/dhimanparas20/Bash-Scripts/main/NginxPIServer.conf https://raw.githubusercontent.com/dhimanparas20/Bash-Scripts/main/cronjob.sh

#Setting up Nginx
cp /Downloads/NginxPIServer.conf /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/NginxPIServer.conf /etc/nginx/sites-enabled/
nginx -t

#Finally Restarting all the service
systemctl restart docker && systemctl status docker --no-pager
systemctl restart mongod && systemctl status mongod --no-pager
systemctl restart nginx && systemctl status nginx --no-pager
systemctl restart mosquitto && systemctl status mosquitto --no-pager

#clone and run Mongo Admin Pannel
cd
git clone https://github.com/dhimanparas20/Mongo-Admin-Pannel.git MongoAdminPannel
cd MongoAdminPannel && docker build -t mongo_admin_pannel .
docker run -d --network=host --name mongo_admin_pannel mongo_admin_pannel
cd

#Writing a cron file
export EDITOR=nano
temp_cron=$(mktemp)
echo "@reboot $(pwd)/Downloads/cronjob.sh" >> "$temp_cron"
crontab "$temp_cron"
rm "$temp_cron"
echo "Cron job added successfully."

#Done
clear
echo "---------------------------------------------------------------------------------"
echo "                                     DONE :-)                                    "
echo "---------------------------------------------------------------------------------"
