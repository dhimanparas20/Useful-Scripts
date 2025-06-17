# Utility alias
alias cls="clear"  # Clear the terminal screen

# =============================
# Docker Container Management
# =============================
alias dps="docker compose ps -a"                   # List all containers (running and stopped)
alias dstart="docker compose start"                 # Start a stopped container
alias dstop="docker compose stop"                   # Stop a running container
alias drestart="docker compose restart"             # Restart a container
alias drm="docker compose rm -f "                   # Forcefully remove a container
alias dlog="docker compose logs -f"                # Tail logs of a container
alias dexec="docker compose exec "                  # Execute a command in a running container
alias dkill="docker compose kill"                   # Kill a running container
alias dinspect="docker inspect"                     # Inspect a container

# ============================
# Docker Image Management
# ============================
alias dimg="docker images"                          # List all images
alias drmi="docker rmi -f "                         # Forcefully remove an image
alias drmiunused="docker image prune -f"            # Remove all unused images
alias dprune="docker image prune -f"                # Prune unused images
alias dbuild="docker compose build"                 # Build services from compose file
alias dexport="docker export -o"                    # Export a container to a tarball
alias dimport="docker import"                       # Import a container tarball
alias dsnapshot="docker checkpoint --create-image"  # Create a snapshot of a container
alias drestore="docker restore"                     # Restore a container from a snapshot

# ================================
# Docker Volume Management
# ================================
alias dvlist="docker volume ls"                     # List all volumes
alias dvcreate="docker volume create"               # Create a new volume
alias dvinspect="docker volume inspect"             # Inspect a volume
alias dvremove="docker volume rm"                   # Remove a volume
alias dvprune="docker volume prune -f"              # Remove all unused volumes

# ================================
# Docker Network Management
# ================================
alias dnlist="docker network ls"                    # List all networks
alias dncreate="docker network create"              # Create a new network
alias dninspect="docker network inspect"            # Inspect a network
alias dnremove="docker network rm"                  # Remove a network
alias dnprune="docker network prune"                # Remove all unused networks

# ================================
# Docker Compose Management
# ================================
alias dup="docker compose up"                       # Bring up services defined in a compose file
alias dup-d="docker compose up -d"                  # Bring up services in detached mode
alias dbuildup="docker compose up --build"          # Build and bring up services
alias dbuildup-d="docker compose up --build -d"     # Build and bring up services in detached mode
alias ddown="docker compose down"                   # Bring down services defined in a compose file
alias ddownrmi="docker compose down --rmi all"      # Bring down services and remove images

# ============================
# Docker System Management
# ============================
alias dinfo="docker info"                           # Display detailed Docker system information
alias dstats="docker stats --all"                   # Display resource usage for all containers
alias dtop="docker top"                             # Display top-like stats for a container
alias dclean="docker system prune -a"               # Prune unused containers, images, and volumes
alias dcleanf="docker system prune --all --volumes --force"  # Aggressively prune all

clear
ls
