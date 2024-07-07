#The script must be run uisng sudo
# The script installs the following packages: Nginx,MongoDB,MosquittoMQTT,Docker,neofetch,ngrok,git,snapd,ufw
#The script also setups some of configs wherever needed
# HOW to run ?
# wget https://raw.githubusercontent.com/dhimanparas20/Bash-Scripts/main/AIO_SERVER_INSTALL_SETUP.sh && chmod +x AIO_SERVER_INSTALL_SETUP.sh && time sudo ./AIO_SERVER_INSTALL_SETUP.sh


#Start
clear
#!/bin/bash

# Enable immediate exit on error
set -e

# Check if the script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script with sudo:"
    echo "time sudo ./AIO_PI-OS_ServerSetup.sh"
    exit 1
fi

#The Basics
apt update
apt upgrade -y
apt install git snapd python3 python3-pip nginx mosquitto mosquitto-clients ufw neofetch lolcat net-tools htop network-manager -y
#install ngrok
snap install ngrok
clear
neofetch
sleep 2

#Install Docker
clear
echo "---------------------------------------------------------------------------------"
echo "                                 Installing Docker                               "
echo "---------------------------------------------------------------------------------"
sleep 2
curl -sSL https://get.docker.com | sh

# Allow installing pip modules globally
set +e
sudo mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old
set -e

#Docker compose
clear
echo "---------------------------------------------------------------------------------"
echo "                            Installing Docker Compose                            "
echo "---------------------------------------------------------------------------------"
sleep 2
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#Store git passwords and add user signature
clear
echo "---------------------------------------------------------------------------------"
echo "                                 Adding Git Configs                              "
echo "---------------------------------------------------------------------------------"
sleep 2
git config --global user.name "dhimanparas20"
git config --global user.email "dhimanparas20@gmail.com"
git config --global credential.helper cache
git config --global credential.helper store
