# regestries location : /etc/containers/registries.conf
# [registries.search]
# registries = ["docker.io", "quay.io", "registry.access.redhat.com"]

# Utility alias
alias cls="clear"  # Clear the terminal screen

# =============================
# Podman Container Management
# =============================
alias pps="podman ps -a"                      # List all containers (running and stopped)
alias pstart="podman start"                   # Start a stopped container
alias pstop="podman stop"                     # Stop a running container
alias prestart="podman restart"               # Restart a container
alias prestartall="podman restart $(podman ps -q)"  # Restart all running containers
alias pstopall="podman stop $(podman ps -q)"        # Stop all running containers
alias prm="podman rm -f "                     # Forcefully remove a container
alias prmall="podman rm -f $(podman ps -aq)"  # Remove all containers
alias plogs="podman logs -f"                  # Tail logs of a container
alias pexec="podman exec -it "                # Execute a command in a running container
alias pkill="podman kill"                     # Kill a running container
alias pinspect="podman inspect"               # Inspect a container

# ============================
# Podman Image Management
# ============================
alias pimg="podman images"                    # List all images
alias prmi="podman rmi -f "                   # Forcefully remove an image
alias prmiunused="podman image prune -f"      # Remove all unused images
alias pprune="podman image prune -f"          # Prune unused images
alias pbuild="podman build -t"                # Build an image from a Dockerfile
alias pexport="podman export -o"              # Export a container to a tarball
alias pimport="podman import"                 # Import a container tarball
alias psnapshot="podman checkpoint --create-image"  # Create a snapshot of a container
alias prestore="podman restore"               # Restore a container from a snapshot

# ================================
# Podman Volume Management
# ================================
alias pvlist="podman volume ls"               # List all volumes
alias pvcreate="podman volume create"         # Create a new volume
alias pvinspect="podman volume inspect"       # Inspect a volume
alias pvremove="podman volume rm"             # Remove a volume
alias pvprune="podman volume prune -f"        # Remove all unused volumes
alias pvolclear="podman volume rm $(podman volume ls -q)"  # Remove all volumes

# ================================
# Podman Network Management
# ================================
alias pnlist="podman network ls"              # List all networks
alias pncreate="podman network create"        # Create a new network
alias pninspect="podman network inspect"      # Inspect a network
alias pnremove="podman network rm"            # Remove a network
alias pnprune="podman network prune"          # Remove all unused networks

# ================================
# Podman Compose Management
# ================================
alias pup="podman-compose up"                 # Bring up services defined in a compose file
alias pup-d="podman-compose up -d"            # Bring up services in detached mode
alias pbuild="podman-compose build"           # Build services defined in a compose file
alias pbuildup="podman-compose up --build"    # Build and bring up services
alias pbuildup-d="podman-compose up --build -d" # Build and bring up services in detached mode
alias pdown="podman-compose down"             # Bring down services defined in a compose file
alias pdownrmi="podman-compose down --rmi all" # Bring down services and remove images

# ============================
# Podman System Management
# ============================
alias pinfo="podman info"                     # Display detailed Podman system information
alias pstats="podman stats --all"             # Display resource usage for all containers
alias ptop="podman top"                       # Display top-like stats for a container
alias pclean="podman system prune -a"         # Prune unused containers, images, and volumes
alias pcleanf="podman system prune --all --volumes --force"  # Aggressively prune all unused resources
alias pcleanall="podman system prune --all --force"  # Clean up everything unused

clear
ls

