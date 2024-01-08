sudo apt update
sudo apt upgrade -y 
sudo apt install nginx python3 python3-pip certbot python3-certbot-nginx -y


# #OTHER Important Commands
# sudo ln -s /etc/nginx/sites-available/mstservices /etc/nginx/sites-enabled/
# sudo nginx -t
# sudo systemctl stop nginx
# sudo systemctl start nginx
# sudo systemctl enable nginx
# sudo systemctl status nginx
# sudo certbot certonly --standalone -d mstservices.online -d www.mstservices.online
# docker build -t flask-app .
# docker run -d -p 5000:5000 flask-app
# docker run -d --network==host flask-app

# installing and setup docker compose
# sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose
# docker-compose --version
# sudo docker-compose up -d --build --scale app=2 
# # Nginx logs
# sudo cat /var/log/nginx/error.log
#  sudo lsof -i :80
#  sudo kill -9 
# /etc/letsencrypt/live/lostnfound.tech/fullchain.pem
# /etc/letsencrypt/live/lostnfound.tech/privkey.pem
# sudo docker logs lostnfound-nginx-1
# chmod 777 /home/ken/lostNfound/fullchain.pem
