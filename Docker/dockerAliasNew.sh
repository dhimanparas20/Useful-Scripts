# Utility alias
alias cls="clear"  # Clear the terminal screen

# =============================
# Docker Container Management
# =============================
alias dps="sudo docker ps -a"                      # List all containers (running and stopped)
alias dstart="sudo docker start"                   # Start a stopped container
alias dstop="sudo docker stop"                     # Stop a running container
alias drestart="sudo docker restart"               # Restart a container
alias drestartall="sudo docker restart $(sudo docker ps -q)"  # Restart all running containers
alias dstopall="sudo docker stop $(sudo docker ps -q)"        # Stop all running containers
alias drm="sudo docker rm -f "                     # Forcefully remove a container
alias drmall="sudo docker rm -f $(sudo docker ps -aq)"  # Remove all containers
alias dlogs="sudo docker logs -f"                  # Tail logs of a container
alias dexec="sudo docker exec -it "                # Execute a command in a running container
alias dkill="sudo docker kill"                     # Kill a running container
alias dinspect="sudo docker inspect"               # Inspect a container

# ============================
# Docker Image Management
# ============================
alias dimg="sudo docker images"                    # List all images
alias drmi="sudo docker rmi -f "                   # Forcefully remove an image
alias drmiunused="sudo docker image prune -f"      # Remove all unused images
alias dprune="sudo docker image prune -f"          # Prune unused images
alias dbuild="sudo docker build -t"                # Build an image from a Dockerfile
alias dexport="sudo docker export -o"              # Export a container to a tarball
alias dimport="sudo docker import"                 # Import a container tarball
alias dsnapshot="sudo docker checkpoint --create-image"  # Create a snapshot of a container
alias drestore="sudo docker restore"               # Restore a container from a snapshot

# ================================
# Docker Volume Management
# ================================
alias dvlist="sudo docker volume ls"               # List all volumes
alias dvcreate="sudo docker volume create"         # Create a new volume
alias dvinspect="sudo docker volume inspect"       # Inspect a volume
alias dvremove="sudo docker volume rm"             # Remove a volume
alias dvprune="sudo docker volume prune -f"        # Remove all unused volumes
alias dvolclear="sudo docker volume rm $(sudo docker volume ls -q)"  # Remove all volumes

# ================================
# Docker Network Management
# ================================
alias dnlist="sudo docker network ls"              # List all networks
alias dncreate="sudo docker network create"        # Create a new network
alias dninspect="sudo docker network inspect"      # Inspect a network
alias dnremove="sudo docker network rm"            # Remove a network
alias dnprune="sudo docker network prune"          # Remove all unused networks

# ================================
# Docker Compose Management
# ================================
alias dup="sudo docker compose up"                 # Bring up services defined in a compose file
alias dup-d="sudo docker compose up -d"            # Bring up services in detached mode
alias dbuild="sudo docker compose build"           # Build services defined in a compose file
alias dbuildup="sudo docker compose up --build"    # Build and bring up services
alias dbuildup-d="sudo docker compose up --build -d" # Build and bring up services in detached mode
alias ddown="sudo docker compose down"             # Bring down services defined in a compose file
alias ddownrmi="sudo docker compose down --rmi all" # Bring down services and remove images

# ============================
# Docker System Management
# ============================
alias dinfo="sudo docker info"                     # Display detailed Docker system information
alias dstats="sudo docker stats --all"             # Display resource usage for all containers
alias dtop="sudo docker top"                       # Display top-like stats for a container
alias dclean="sudo docker system prune -a"         # Prune unused containers, images, and volumes
alias dcleanf="sudo docker system prune --all --volumes --force"  # Aggressively prune all

clear
ls
