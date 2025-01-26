# regestries location : /etc/containers/registries.conf
# [registries.search]
# registries = ["docker.io", "quay.io", "registry.access.redhat.com"]

alias pps="podman ps -a"
alias pimg="podman images"
alias prmi="podman rmi -f "
alias prm="podman rm -f "
alias pup="podman compose up"
alias pup-d="podman compose up -d"
alias pbuild="podman compose build "
alias plog="podman logs -f "
alias pexec="podman exec -it "
alias pbuildup="podman compose up --build"
alias pbuildup-d="podman compose up --build -d"
alias pdown="podman compose down"
alias pdownrmi="podman compose down --rmi all"
alias pprune="podman image prune -f"
alias pclean="podman system prune -a"
alias pcleanf="podman system prune --all --volumes --force"
alias pexec="podman exec -it "
alias pinfo="podman info"                      # View detailed podman system information
alias pstats="podman stats --all"             # View resource usage for all containers
alias ptop="podman top"                       # Display top-like statistics for a container
alias plogs="podman logs -f"                  # Tail logs of a container
alias pinspect="podman inspect"               # Inspect a container or image
alias pkill="podman kill"                     # Kill a running container
alias prestart="podman restart"               # Restart a container
alias pstop="podman stop"                     # Stop a running container
alias pstart="podman start"                   # Start a stopped container
alias prename="podman rename"                 # Rename a container
alias pvlist="podman volume ls"               # List all volumes
alias pvcreate="podman volume create"         # Create a new volume
alias pvinspect="podman volume inspect"       # Inspect a volume
alias pvremove="podman volume rm"             # Remove a volume
alias pvprune="podman volume prune -f"        # Remove all unused volumes
alias pnlist="podman network ls"              # List all networks
alias pncreate="podman network create"        # Create a new network
alias pninspect="podman network inspect"      # Inspect a network
alias pnremove="podman network rm"            # Remove a network
alias pnprune="podman network prune"          # Remove all unused networks
alias pcleanall="podman system prune --all --force"  # Clean up everything unused
alias pexport="podman export -o"                    # Export a container to a tarball
alias pimport="podman import"                       # Import a container tarball
alias psnapshot="podman checkpoint --create-image"  # Create a snapshot of a container
alias prestore="podman restore"                     # Restore a container from a snapshot
alias pbuild="podman build -t"                      # Build an image from a Dockerfile
alias prestartall="podman restart $(podman ps -q)"  # Restart all running containers
alias pstopall="podman stop $(podman ps -q)"        # Stop all running containers
alias prmall="podman rm -f $(podman ps -aq)"        # Remove all containers
alias prmiunused="podman image prune -f"           # Remove all unused images
alias pvolclear="podman volume rm $(podman volume ls -q)" # Clear all volumes
alias cls="clear"
clear
ls

