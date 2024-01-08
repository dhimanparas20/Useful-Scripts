# https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/
sudo apt-get install gnupg curl
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl daemon-reload
sudo systemctl status mongod
sudo systemctl enable mongod
sudo systemctl restart mongod

# if system doesnt support AVX then run mongo on docker 
# docker run -d -p 27017:27017 mongo:4.4
# docker exec -it 881e7c2e332b mongo  #Replace 881e7c2e332b with your actual MongoDB container ID.
# docker network create my-network
# docker network connect my-network 881e7c2e332b  # MongoDB container
# docker network connect my-network tgbot        # Other containers
# docker network connect my-network mstapi
