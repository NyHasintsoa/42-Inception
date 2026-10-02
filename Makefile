# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: nramalan <nramalan@student.42antananari    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/10/01 19:29:49 by nramalan          #+#    #+#              #
#    Updated: 2026/10/02 16:35:44 by nramalan         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

.SILENT:

DOCKER := docker
DOCKER_COMPOSE := $(DOCKER) compose

VOLUMES_PATH = $(HOME)/data/
VOLUMES_NAMES = mariadb wordpress portainer
VOLUMES_DIR = $(addprefix $(VOLUMES_PATH), $(VOLUMES_NAMES))

COMPOSE_FILE := srcs/docker-compose.yml

.DEFAULT_GOAL := help

##-----------------------------------
## Usefull Commands
##-----------------------------------
.PHONY: run
run: docker-up ## Alias of docker-up

.PHONY: clean
clean: docker-down ## Alias of docker-down

.PHONY: fclean
fclean: docker-down docker-prune ## Stop and clean docker containers

##
##-----------------------------------
## Docker Commands
##-----------------------------------
.PHONY: docker-up
docker-up: $(VOLUMES_DIR) ## Start docker containers
	echo "Start docker containers"
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d --build

.PHONY: docker-down
docker-down: ## Stop docker containers
	echo "Stop docker containers"
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down

.PHONY: docker-logs
docker-logs: ## Show docker logs
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f

.PHONY: docker-prune
docker-prune: ## Clean docker
	$(DOCKER) system prune -af

##
##-----------------------------------
## Others Commands
##-----------------------------------
.PHONY: help
help: ## List commands
	grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

##

#-----------------------------------
# Dependencies
#-----------------------------------
$(VOLUMES_DIR):
	echo "Creating usefull directory: $(VOLUMES_DIR)"
	mkdir -p $(VOLUMES_DIR)
