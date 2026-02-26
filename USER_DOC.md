# User Documentation

## Services Overview

This stack provides a WordPress website accessible via HTTPS:

| Service | Description |
|---------|-------------|
| **NGINX** | Reverse proxy handling HTTPS (port 443) with TLSv1.2/TLSv1.3 |
| **WordPress** | Content management system with php-fpm |
| **MariaDB** | Database storing WordPress content and user data |

## Starting and Stopping

### Start the project

```bash
make        # Build and start (foreground, shows logs)
make run    # Start in background (detached mode)
```

### Stop the project

```bash
make clean  # Stop all containers and remove Docker volumes
make fclean # Stop, remove volumes AND delete data directories
```

### View logs

```bash
make logs
```

## Accessing the Website

1. Ensure `elopin.42.fr` resolves to your machine IP. Add to `/etc/hosts` if needed:
   ```
   127.0.0.1 elopin.42.fr
   ```
2. Open a browser and go to `https://elopin.42.fr`
3. Accept the self-signed certificate warning

## Administration Panel

1. Go to `https://elopin.42.fr/wp-admin`
2. Log in with the admin credentials (username defined in `srcs/.env`, password in `secrets/credentials.txt`)

## Credentials

Credentials are stored securely and are NOT committed to the git repository:

| File | Content |
|------|---------|
| `srcs/.env` | Non-sensitive configuration (usernames, domain, DB name) |


## Checking Services

Verify all containers are running:

```bash
docker ps
```

You should see 3 containers (`nginx`, `wordpress`, `mariadb`) all with status **Up**.

Check individual service health:

```bash
docker inspect --format='{{.State.Health.Status}}' mariadb
docker inspect --format='{{.State.Health.Status}}' wordpress
```

Both should return `healthy`.
