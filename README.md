*This project has been created as part of the 42 curriculum by elopin.*

# Inception

## Description

Inception is a system administration project that uses Docker to set up a small infrastructure composed of different services running inside a virtual machine.

The infrastructure consists of:
- **NGINX** - Web server with TLSv1.2/TLSv1.3, the only entry point via port 443
- **WordPress + php-fpm** - CMS serving the website
- **MariaDB** - Relational database for WordPress

All services run in dedicated containers orchestrated by Docker Compose, communicating through a Docker network with persistent data stored in named volumes.

### Virtual Machines vs Docker

Virtual machines emulate entire operating systems with their own kernel, providing strong isolation but consuming significant resources (RAM, CPU, disk). Docker containers share the host kernel and use namespaces/cgroups for isolation, making them lightweight, faster to start, and more efficient. For this project, Docker is ideal because we run multiple lightweight services that need to communicate without the overhead of full OS virtualization.

### Secrets vs Environment Variables

Environment variables are simple to configure but can be exposed through `docker inspect`, process listings, or logs. Docker secrets mount sensitive data as files in `/run/secrets/` inside containers, readable only by the target service and never stored in the image layer. This project uses Docker secrets for all passwords and environment variables for non-sensitive configuration.

### Docker Network vs Host Network

Host networking removes network isolation, exposing all container ports directly on the host. Docker bridge networks (used here) create isolated virtual networks where containers communicate by service name via internal DNS, while only explicitly published ports (443) are accessible from outside.

### Docker Volumes vs Bind Mounts

Bind mounts map a host path directly into a container, creating tight coupling with the host filesystem. Docker named volumes are managed by Docker, providing better portability and lifecycle management. This project uses named volumes configured to store data at `/home/elopin/data/` on the host as required.

## Instructions

### Prerequisites

- Docker Engine and Docker Compose
- Virtual machine running Debian
- GNU Make

### Setup

1. Clone the repository
2. Create the secrets files in `secrets/`:
   - `secrets/db_password.txt` - MariaDB user password
   - `secrets/db_root_password.txt` - MariaDB root password
   - `secrets/credentials.txt` - WordPress admin password
3. Create the `.env` file in `srcs/` with your configuration
4. Add `elopin.42.fr` to `/etc/hosts` pointing to `127.0.0.1`

### Running

```bash
make        # Build and start all containers
make run    # Start in detached mode
make logs   # View container logs
make clean  # Stop and remove volumes
make fclean # Full cleanup including data directories
make re     # Full rebuild
```

### Accessing

- Website: https://elopin.42.fr
- Admin panel: https://elopin.42.fr/wp-admin

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress CLI](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

### AI Usage

AI tools were used as a learning aid to understand Docker networking concepts, debug TLS configuration, and generate documentation structure. All generated content was reviewed, tested, and adapted to the project requirements.
