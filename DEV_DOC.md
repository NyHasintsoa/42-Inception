# Developer Documentation

## Overview

This project is a Docker-based multi-service web environment built for the 42 Inception exercise. It groups WordPress, MariaDB, NGINX, Redis, and several bonus services into a single Compose stack.

A developer working on this project should be able to set up the environment from scratch, build the application, manage containers, and understand where persistent data is stored.

## Prerequisites

Before starting the project, ensure the following are installed on the host machine:

- Docker Engine
- Docker Compose
- a Unix-like shell such as bash or fish
- permissions to create directories under `$HOME/data`

## Repository structure

The project is organized as follows:

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── db_password.txt
│   └── db_root_password.txt
├── srcs/
│   ├── .env.example
│   ├── .env
│   ├── docker-compose.yml
│   └── requirements/
│       ├── mariadb/
│       ├── nginx/
│       ├── wordpress/
│       └── bonus/
```

## Environment setup from scratch

### 1. Create the environment file

Copy the example environment file:

```bash
cp srcs/.env.example srcs/.env
```

Then edit `srcs/.env` and set the required values, including:

- `DOMAIN_NAME`
- `DB_USER`
- `DB_NAME`
- `REDIS_PASSWORD`
- `WP_TITLE`
- `WP_ADMIN_USER`
- `WP_ADMIN_PASSWORD`
- `WP_ADMIN_EMAIL`
- `WP_USER`
- `WP_USER_PASSWORD`
- `WP_USER_EMAIL`
- `FTP_USER`
- `FTP_PASSWORD`

### 2. Create database secret files

The project expects the following files to exist in the root `secrets/` directory:

```text
secrets/db_password.txt
secrets/db_root_password.txt
```

These files are mounted as Docker secrets and used by MariaDB during initialization.

### 3. Prepare persistent host directories

The Compose file uses bind-mounted host paths in `$HOME/data`:

```text
$HOME/data/mariadb
$HOME/data/wordpress
$HOME/data/portainer
```

The Makefile creates these directories automatically when starting the project, but they can also be created manually.

## Build and launch with Docker Compose

### Start the stack

```bash
make run
```

Equivalent manual command:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

This will:

- build all Docker images
- create the Docker network named `inception`
- mount the required volumes
- start the services in the background

### Stop the stack

```bash
make clean
```

Equivalent manual command:

```bash
docker compose -f srcs/docker-compose.yml down
```

### Follow logs

```bash
make docker-logs
```

Or directly:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

### Full cleanup

```bash
make fclean
```

This stops the containers and prunes Docker resources.

## Container management commands

Useful commands for developers:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Check the state of the services.

```bash
docker compose -f srcs/docker-compose.yml stop
```

Stop all containers.

```bash
docker compose -f srcs/docker-compose.yml start
```

Restart stopped containers.

```bash
docker compose -f srcs/docker-compose.yml restart
```

Restart the whole stack.

```bash
docker compose -f srcs/docker-compose.yml logs <service_name>
```

Inspect a specific service log.

## Volume and persistence model

The Compose file defines persistent bind mounts so that data survives across container restarts.

### Main persistent data locations

| Volume           | Host path              | Purpose                             |
| ---------------- | ---------------------- | ----------------------------------- |
| `mariadb-data`   | `$HOME/data/mariadb`   | MariaDB data files                  |
| `wordpress-data` | `$HOME/data/wordpress` | WordPress content, plugins, uploads |
| `portainer-data` | `$HOME/data/portainer` | Portainer data and configuration    |

These bind mounts ensure that the application state persists on the host machine rather than being lost when the containers are restarted or recreated.

## Service architecture

The project defines a shared Docker network named `inception`.

### Core services

- `nginx` handles HTTPS traffic and forwards requests to WordPress
- `wordpress` runs the WordPress application with PHP-FPM
- `mariadb` stores the WordPress database
- `redis` provides object-caching support

### Bonus services

- `adminer` provides a database administration UI
- `ftp` provides FTP access to the site content
- `static-website` hosts a standalone HTML page
- `portainer` provides a Docker management interface

## Data and initialization flow

On first startup:

1. MariaDB initializes the database and creates the configured user and database.
2. WordPress downloads and configures itself if missing.
3. WP-CLI installs WordPress and creates the admin account.
4. Redis is configured as the object cache backend.
5. NGINX generates a local TLS certificate and serves the website over HTTPS.

Because the volumes are persistent, subsequent startups reuse the existing database and WordPress content instead of reinitializing them unless the data directories are explicitly removed.

## Practical development notes

- Use `docker compose ... ps` and `docker compose ... logs -f` regularly to confirm health.
- If secrets or environment variables are changed, recreate the stack if necessary.
- Certificates are generated locally and are self-signed, so browsers will show warnings in local testing.
- This is a local teaching/development setup and should not be treated as a production-hardened deployment.

## Summary

This project demonstrates how to build a multi-container application environment using Docker Compose. From a developer perspective, the important tasks are:

- prepare the `.env` file and secrets
- start the stack with Make or Compose
- monitor services with logs and status checks
- understand the persistent host directories used by MariaDB, WordPress, and Portainer

This setup keeps the project reproducible, easy to inspect, and practical for local development and teaching use.
