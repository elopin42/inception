# Developer Documentation

## Setting Up the Environment

### Prerequisites

- Docker Engine (20.10+)
- Docker Compose (v2+)
- GNU Make
- A virtual machine running Debian

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone <repo-url>
   cd inception
   ```

2. **Create secrets files:**
   ```bash
   mkdir -p secrets
   echo "your_db_password" > secrets/db_password.txt
   echo "your_root_password" > secrets/db_root_password.txt
   echo "your_wp_admin_password" > secrets/credentials.txt
   ```

3. **Create the environment file:**
   ```bash
   cp srcs/.env.example srcs/.env
   # Edit srcs/.env with your values
   ```

4. **Configure DNS:**
   Add to `/etc/hosts`:
   ```
   127.0.0.1 elopin.42.fr
   ```

## Building and Launching

### Makefile Commands

| Command | Description |
|---------|-------------|
| `make` / `make all` | Create data directories, build images, start containers |
| `make run` | Start containers in detached mode |
| `make logs` | Follow container logs in real-time |
| `make clean` | Stop containers and remove Docker volumes |
| `make fclean` | Clean + remove host data directories |
| `make re` | Full clean and rebuild |

### How It Works

The Makefile calls `docker-compose -f srcs/docker-compose.yml` to orchestrate the build. Each service has its own Dockerfile in `srcs/requirements/<service>/`:

- `srcs/requirements/nginx/Dockerfile`
- `srcs/requirements/wordpress/Dockerfile`
- `srcs/requirements/mariadb/Dockerfile`

Docker secrets are defined in `docker-compose.yml` and reference files from the `secrets/` directory. They are mounted as files under `/run/secrets/` inside the containers.

## Managing Containers and Volumes

### Container Management

```bash
# List running containers
docker ps

# Access a container shell
docker exec -it nginx /bin/bash
docker exec -it wordpress /bin/bash
docker exec -it mariadb /bin/bash

# Restart a single service
docker-compose -f srcs/docker-compose.yml restart nginx

# View logs for a specific service
docker-compose -f srcs/docker-compose.yml logs -f wordpress
```

### Volume Management

```bash
# List volumes
docker volume ls

# Inspect a volume
docker volume inspect srcs_wp_data
docker volume inspect srcs_db_data
```

## Data Storage and Persistence

Data is stored using Docker named volumes mapped to host directories:

| Volume | Host Path | Container Path | Content |
|--------|-----------|----------------|---------|
| `wp_data` | `/home/elopin/data/wordpress` | `/var/www/wordpress` | WordPress files |
| `db_data` | `/home/elopin/data/mariadb` | `/var/lib/mysql` | MariaDB database |

Data persists across container restarts and rebuilds as long as the host directories exist. Running `make fclean` deletes these directories and all data.

## Project Structure

```
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── .gitignore
├── secrets/                      # NOT committed to git
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env                      # NOT committed to git
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── setup.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   └── conf/
        │       └── nginx.conf
        └── wordpress/
            ├── Dockerfile
            └── tools/
                └── entrypoint.sh
```
