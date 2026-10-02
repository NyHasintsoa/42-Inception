# User documentation

## Overview

This project runs a complete web stack in Docker containers. It provides:

- a website powered by WordPress
- a secure HTTPS entry point with NGINX
- a MariaDB database
- a Redis cache layer
- admin and support tools such as Adminer, FTP, Portainer, and a static showcase page

The purpose is to make a small hosting environment easy to start, manage, and inspect locally.

## Services provided by the stack

The stack includes the following services:

| Service          | Role                                    | Access                                             |
| ---------------- | --------------------------------------- | -------------------------------------------------- |
| `nginx`          | HTTPS reverse proxy and web entry point | `https://<DOMAIN_NAME>`                            |
| `wordpress`      | WordPress site and admin interface      | same as above                                      |
| `mariadb`        | Database for WordPress                  | internal only, exposed as 3306 for local debugging |
| `redis`          | Cache backend for WordPress             | internal only, exposed on 6379                     |
| `adminer`        | Database admin UI                       | `http://localhost:8080`                            |
| `ftp`            | File transfer service                   | `ftp://<DOMAIN_NAME>` on port 21                   |
| `portainer`      | Docker management interface             | `http://localhost:9090`                            |
| `static-website` | Example static landing page             | `http://localhost:8000`                            |

## Start the project

From the root of the repository, run:

```bash
make run
```

This command builds the images if needed and starts all containers in the background.

You can also start it manually with Docker Compose:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

## Stop the project

To stop the services:

```bash
make clean
```

This is equivalent to:

```bash
docker compose -f srcs/docker-compose.yml down
```

## Access the website and administration panel

### Website

Once the stack is running, open the site in a browser:

```text
https://<DOMAIN_NAME>
```

If you are using a local domain name such as `localhost`, the address is likely:

```text
https://localhost
```

> The site uses a self-signed certificate, so your browser may warn that the certificate is not trusted. This is expected in a local development environment.

### WordPress administration panel

The main administration panel is available at:

```text
https://<DOMAIN_NAME>/wp-admin
```

Use the administrator credentials created in the environment file.

### Adminer

Adminer is available at:

```text
http://localhost:8080
```

Use the MariaDB credentials from the project secrets and environment configuration.

### Portainer

Portainer is available at:

```text
http://localhost:9090
```

This gives a graphical interface for checking container state and managing Docker resources.

## Locate and manage credentials

Credentials are stored in two places:

### 1. Environment variables

The main configuration is stored in:

```text
srcs/.env
```

This file contains the service configuration such as:

- `DOMAIN_NAME`
- `DB_USER`
- `DB_NAME`
- `WP_ADMIN_USER`
- `WP_ADMIN_PASSWORD`
- `WP_ADMIN_EMAIL`
- `WP_USER`
- `WP_USER_PASSWORD`
- `WP_USER_EMAIL`
- `FTP_USER`
- `FTP_PASSWORD`

If the file is missing, copy the example file:

```bash
cp srcs/.env.example srcs/.env
```

### 2. Docker secrets

Database secrets are stored in the repository root under:

```text
secrets/db_password.txt
secrets/db_root_password.txt
```

These files are mounted into the MariaDB container and used for database setup and authentication.

## Check that the services are running correctly

### Check container status

```bash
docker compose -f srcs/docker-compose.yml ps
```

This shows whether all services are up and running.

### Follow logs

To inspect live logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

This is useful when debugging startup issues or checking whether WordPress and the database are reachable.

### Quick validation checklist

- the `nginx` container is running
- the `wordpress` container is running
- the `mariadb` container is running
- `https://<DOMAIN_NAME>` loads without errors
- the WordPress admin page responds
- `http://localhost:8080` opens Adminer
- `http://localhost:9090` opens Portainer

## Full cleanup

If you want to remove all containers and Docker resources created by the project:

```bash
make fclean
```

This stops the stack and prunes Docker resources.

## Notes

- The project stores persistent data on the host filesystem under `$HOME/data`.
- The website and database remain available after restart as long as the bind-mounted volumes are not deleted.
- This project is intended for local development and educational use, not for a hardened production deployment.

For implementation and setup details, see [DEV_DOC.md](DEV_DOC.md).
