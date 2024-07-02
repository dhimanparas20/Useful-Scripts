# https://raspberrypi.stackexchange.com/questions/143653/failure-when-trying-to-run-mongodb-on-raspberry-pi-3-b-ubuntu-23-04

wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
    
echo "deb [ arch=arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list

sudo apt-get update --allow-insecure-repositories

sudo apt-get install -y mongodb-org=4.4.1  mongodb-org-server=4.4.1  mongodb-org-shell=4.4.1 mongodb-org-mongos=4.4.1 mongodb-org-tools=4.4.1 
echo "mongodb-org hold" | sudo dpkg --set-selections &&
echo "mongodb-org-server hold" | sudo dpkg --set-selections &&
echo "mongodb-org-shell hold" | sudo dpkg --set-selections &&
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections &&
echo "mongodb-org-tools hold" | sudo dpkg --set-selections

sudo systemctl start mongod
sudo systemctl enable mongod
