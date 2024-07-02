sudo echo "[Unit]
Description=Docker Container 1
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStartPre=-/usr/bin/docker stop container-1
ExecStartPre=-/usr/bin/docker rm container-1
ExecStart=/usr/bin/docker run -d -p 5000:5000 --name container-1 site
ExecStop=/usr/bin/docker stop container-1

[Install]
WantedBy=multi-user.target
" >> /etc/systemd/system/docker-container-1.service

sudo systemctl daemon-reload
sudo systemctl enable docker-container-1.service
sudo systemctl start docker-container-1.service
sudo systemctl status docker-container-1.service
