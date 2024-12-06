#!/bin/bash

# The script must be run using sudo
# The script also sets up some configurations wherever needed
# HOW to run ?
# wget https://raw.githubusercontent.com/dhimanparas20/Bash-Scripts/main/MAIN_UBUNTU_SERVER_INSTALL_SETUP.sh && chmod +x MAIN_UBUNTU_SERVER_INSTALL_SETUP.sh && time sudo ./MAIN_UBUNTU_SERVER_INSTALL_SETUP.sh

# Start
clear
set -e

# Check if the script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script with sudo:"
    echo "time sudo ./AIO_SERVER_INSTALL_SETUP.sh"
    exit 1
fi

# The Basics
apt update
apt upgrade -y
apt install git snapd python3 python3-pip ufw neofetch net-tools htop network-manager -y

# Install LazyDocker
curl -sSL https://raw.githubusercontent.com/upciti/wakemeops/main/assets/install_repository | sudo bash
apt install lazydocker -y

# Install Docker
clear
echo "---------------------------------------------------------------------------------"
echo "                                 Installing Docker                               "
echo "---------------------------------------------------------------------------------"
sleep 2
wget https://get.docker.com -O install-docker.sh
chmod +x install-docker.sh
./install-docker.sh
rm install-docker.sh

# Store git passwords and add user signature
clear
echo "---------------------------------------------------------------------------------"
echo "                                 Adding Git Configs                              "
echo "---------------------------------------------------------------------------------"
sleep 2
git config --global user.name "dhimanparas20"
git config --global user.email "dhimanparas20@gmail.com"
git config --global credential.helper cache
git config --global credential.helper store

# Install Zsh and OhMyZsh
apt install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# Define the file path for .zshrc
ZSHRC_FILE="$HOME/.zshrc"

# Replace the line that starts with 'plugins=' to add new plugins
sed -i 's/^plugins=(git)/plugins=(git sudo history encode64 copypath zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC_FILE"

# Replace the line that starts with 'ZSH_THEME="roborussel"' with 'ZSH_THEME="bira"'
sed -i 's/^ZSH_THEME="roborussel"/ZSH_THEME="bira"/' "$ZSHRC_FILE"

# Add Docker-related aliases and other commands
{
    echo 'sudo chmod 777 /var/run/docker.sock'
    echo 'alias dps="sudo docker ps -a"'
    echo 'alias dimg="sudo docker images"'
    echo 'alias drmi="sudo docker rmi -f "'
    echo 'alias drm="sudo docker rm -f "'
    echo 'alias dup="sudo docker compose up"'
    echo 'alias dup-d="sudo docker compose up -d"'
    echo 'alias dbuild="sudo docker compose build "'
    echo 'alias dlog="sudo docker logs -f "'
    echo 'alias dbuildup="sudo docker compose up --build"'
    echo 'alias dbuildup-d="sudo docker compose up --build -d"'
    echo 'alias ddown="sudo docker compose down"'
    echo 'alias ddownrmi="sudo docker compose down --rmi all"'
    echo 'alias dprune="sudo docker image prune -f"'
    echo 'alias dclean="sudo docker system prune -a"'
    echo 'clear'
    echo 'neofetch'
    echo 'ls'
} >> "$ZSHRC_FILE"

# Reload the .zshrc file to apply the changes immediately
source "$ZSHRC_FILE"

echo "Docker-related commands, aliases, and plugins added successfully to .zshrc."

# Reboot the system after setup is complete
echo "System setup complete. Rebooting the system..."
