_This project has been created as part of the 42 curriculum by nramalan._

# Description

This project is a Docker-based web infrastructure designed around the Inception requirement of the 42 curriculum. The goal is to build a small but complete hosting environment using multiple containers instead of installing services directly on the host machine.

The stack provides a production-like architecture where each component is isolated and runs in its own container:

- NGINX serves the website over HTTPS and handles TLS termination
- WordPress runs with PHP-FPM as the main application
- MariaDB stores the application data persistently
- Redis handles object caching for WordPress
- additional services such as Adminer, FTP, Portainer, and a static website complete the environment

This project demonstrates how to orchestrate services using Docker Compose, define custom networks, use secrets for sensitive data, and mount persistent storage to retain data across restarts.

# Project description

## Docker and source organization

The project uses Docker to isolate each service in its own lightweight environment. The files are split by role:

- `srcs/docker-compose.yml` orchestrates the full stack
- `srcs/requirements/` contains each container build context and its configuration files
- `secrets/` stores sensitive information such as database credentials
- `Makefile` provides a concise set of commands to build, start, stop, and clean the project

The source structure is intentionally modular:

- each service has its own Dockerfile and configuration directory
- dependencies are isolated by service
- the stack is easy to rebuild and re-run without affecting the host system

## Main design choices

The objective of the architecture is to keep services independent while still allowing them to communicate securely through a dedicated internal network. This allows WordPress to connect to MariaDB and Redis using container names instead of host IPs, which keeps the setup portable and predictable.

The project also uses persistent host-mounted directories to store database and application data outside the containers. This prevents loss of data when containers are recreated or restarted.

## Virtual Machines vs Docker

A virtual machine would run a full guest operating system for each service, which makes it heavier and slower. Docker instead packages only the application and its dependencies in containers, reducing resource usage and startup time while keeping each service isolated.

In practice, Docker is better suited for a school project like this because it provides a lightweight, reproducible environment with fast development iterations and a clear service separation model.

## Secrets vs Environment Variables

Secrets are intended for confidential data such as database passwords and root credentials. They are stored outside the normal environment file and are mounted directly into the relevant container at runtime.

Environment variables are useful for non-sensitive configuration such as the domain name, site title, or WordPress user settings. They are easier to configure and manage, but they should never hold critical credentials.

This project uses both correctly:

- secrets store sensitive database credentials
- environment variables store application configuration values

## Docker Network vs Host Network

The stack uses a dedicated Docker network named `inception`. This lets the containers discover each other by service name and communicate internally without exposing all services directly to the host.

Using a Docker network is safer and cleaner than binding everything to the host network because it keeps the application logically isolated. Host networking is usually reserved for direct low-level networking scenarios, while container-to-container communication is better handled by an internal Docker network.

## Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker itself and are often used when the data should remain in Docker-controlled storage. Bind mounts link a directory in the container to a directory on the host filesystem.

This project uses bind mounts for persistence because it stores data under `$HOME/data` on the host machine, making it easier for the developer to inspect or recover files outside the container lifecycle. This is especially useful in local development and educational environments where persistence and debugging are important.

# Instructions

## Requirements

Before starting the project, make sure Docker is installed and running on the host system.

You also need:

- Docker Compose
- a shell environment
- access to directories under `$HOME/data`

## Configuration

1. Copy the example environment file:

```bash
cp srcs/.env.example srcs/.env
```

2. Edit `srcs/.env` and fill in all required variables such as:

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

3. Ensure the secrets files exist:

```text
secrets/db_password.txt
secrets/db_root_password.txt
```

4. Ensure the required host directories exist or let the Makefile create them automatically:

```text
$HOME/data/mariadb
$HOME/data/wordpress
$HOME/data/portainer
```

## Start the project

Use the Makefile:

```bash
make run
```

Or start it directly with Docker Compose:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

## Stop the project

```bash
make clean
```

This is equivalent to:

```bash
docker compose -f srcs/docker-compose.yml down
```

## View logs

```bash
make docker-logs
```

Or:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

## Full cleanup

```bash
make fclean
```

This removes containers and prunes Docker resources.

## Access points

Once the stack is running, the main endpoints are:

- WordPress: `https://<DOMAIN_NAME>`
- WordPress admin: `https://<DOMAIN_NAME>/wp-admin`
- Adminer: `http://localhost:8080`
- Portainer: `http://localhost:9090`
- Static page: `http://localhost:8000`
- FTP: `ftp://<DOMAIN_NAME>` on port 21

> Note: the certificate is self-signed, so the browser may present a security warning in local development.

# Resources

## References

The following references are relevant to understanding the concepts used in this project:

- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- NGINX official documentation: https://nginx.org/en/docs/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- WordPress developer documentation: https://developer.wordpress.org/
- Redis documentation: https://redis.io/docs/
- OpenSSL documentation: https://www.openssl.org/docs/

## AI usage

AI was used as a support tool during the preparation of this project documentation and technical explanation. In particular, it helped with:

- summarizing the project architecture and service interactions
- drafting the README structure and technical descriptions
- explaining the Docker design choices and the differences between related technologies
- organizing the required documentation sections for clarity and compliance with the exercise rules

The actual implementation of the project was validated against the project files, Docker Compose configuration, and service configuration sources in this repository.

## Additional notes

This project is intended for local development and educational use. It demonstrates a complete containerized architecture with real services, persistent storage, secret handling, and a reverse proxy, while keeping the setup lightweight and reproducible.
