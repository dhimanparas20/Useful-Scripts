export PATH="$PATH:$HOME/bin"
export PATH="$HOME/.local/bin:$PATH"
eval "$(zoxide init zsh)"

# System Aliases
alias cls="clear"
alias docker="docker"
# alias docker="sudo docker"
alias doc="docker compose "
alias ld="lazydocker "

# Git Alias
alias gadd="git add ."
alias gcommit="git commit -m "
alias gpush="git push "

# =============================
# Docker Container Management
# =============================
#alias dps="docker ps -a --format 'table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}'"  # List all containers (running and stopped)
alias dps="docker ps -a --format 'table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}'"
alias dstart="docker start"                   # Start a stopped container
alias dstop="docker stop"                     # Stop a running container
alias drestart="docker restart"               # Restart a container
alias drm="docker rm -f "                     # Forcefully remove a container
alias dlog="docker logs -f"                  # Tail logs of a container
alias dexec="docker exec -it "                # Execute a command in a running container
alias dkill="docker kill"                     # Kill a running container
alias dinspect="docker inspect"               # Inspect a container

# ============================
# Docker Image Management
# ============================
alias dimg="docker images"                    # List all images
alias drmi="docker rmi -f "                   # Forcefully remove an image
alias drmiunused="docker image prune -f"      # Remove all unused images
alias dprune="docker image prune -f"          # Prune unused images
alias dbuild="docker build -t"                # Build an image from a Dockerfile
alias dexport="docker export -o"              # Export a container to a tarball
alias dimport="docker import"                 # Import a container tarball
alias dsnapshot="docker checkpoint --create-image"  # Create a snapshot of a container
alias drestore="docker restore"               # Restore a container from a snapshot

# ================================
# Docker Volume Management
# ================================
alias dvlist="docker volume ls"               # List all volumes
alias dvcreate="docker volume create"         # Create a new volume
alias dvinspect="docker volume inspect"       # Inspect a volume
alias dvremove="docker volume rm"             # Remove a volume
alias dvprune="docker volume prune -f"        # Remove all unused volumes

# ================================
# Docker Network Management
# ================================
alias dnlist="docker network ls"              # List all networks
alias dncreate="docker network create"        # Create a new network
alias dninspect="docker network inspect"      # Inspect a network
alias dnremove="docker network rm"            # Remove a network
alias dnprune="docker network prune"          # Remove all unused networks

# ================================
# Docker Compose Management
# ================================
alias dup="docker compose up"                 # Bring up services defined in a compose file
alias dcstop="docker compose stop "
alias dup-d="docker compose up -d"            # Bring up services in detached mode
alias dbuild="docker compose build"           # Build services defined in a compose file
alias dbuildup="docker compose up --build"    # Build and bring up services
alias dbuildup-d="docker compose up --build -d" # Build and bring up services in detached mode
alias ddown="docker compose down"             # Bring down services defined in a compose file
alias ddownrmi="docker compose down --rmi all" # Bring down services and remove images
alias dclog="docker compose logs -f "          # Tail logs of services
alias dcrestart="docker compose restart "      # Restart services
alias dcexec="docker compose exec -it "        # Execute a command in a running service container


# ============================
# Docker System Management
# ============================
alias dinfo="docker info"                     # Display detailed Docker system information
alias dstats="docker stats --all"             # Display resource usage for all containers
alias dtop="docker top"                       # Display top-like stats for a container
alias dimgclean="docker images | grep '<none>' | awk '{print $3}' | xargs docker rmi"
alias dclean="docker system prune -a"         # Prune unused containers, images, and volumes
alias dcleanf="docker system prune --all --volumes --force"  # Aggressively prune all

# =================================
# Extra Docker Compose Things
# =================================
alias dclog="docker compose logs -f "
alias dcrestart="docker compose restart "
alias dcexec="docker compose exec -it "
alias dcipython="docker compose exec -it app ipython"

# =================================
# Django Commands
# =================================
alias py="python3"
alias activate="python3 -m venv venv && source venv/bin/activate"
alias runserver="uv run python3 manage.py runserver 0.0.0.0:5000  "
alias migrate="uv run python3 manage.py migrate"
alias makemigrations="uv run python3 manage.py makemigrations"


alias down="z ~/Downloads*"
alias desk="z ~/Desktop"
alias work="z ~/Work"
alias proj="z ~/Work/Projects"

## Alias to all the servers
alias raspi='sshpass -p "" ssh mst@raspi.local'
alias server="ssh -i '/location/to/key.pem' ubuntu@ip"
alias server2='sshpass -p "password" ssh root@ip' 

clear
echo "Hello GOD!"
ls
