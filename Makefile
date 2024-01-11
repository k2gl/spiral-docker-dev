# Executables (local)
DOCKER_COMP = docker compose --env-file docker/env/docker-compose.override.env

# Docker container
PHP_CONT_NAME = php

# Executables
PHP_CONT = $(DOCKER_COMP) run $(PHP_CONT_NAME)

# Misc
.DEFAULT_GOAL = help
.PHONY        = help build up run down logs php

##—————— ꩜ spiral_docker_dev ——————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s \033[0m %s\n", $$1 e, $$2}' |  sed -e 's/\[32m##/[33m/'

env-create: ## Create environment variables
	cp -i docker/env/docker-compose.env docker/env/docker-compose.override.env

install: ## Create environment variables and build the Docker images
	make env-create
	make build
	make up
	make ps

##—————— 🐳 Docker ——————
build: ## Builds the Docker images (with cache)
	$(DOCKER_COMP) build --pull $(PHP_CONT_NAME)

rebuild: ## Rebuilds the Docker images
	$(DOCKER_COMP) build --no-cache

ps: ## List containers
	$(DOCKER_COMP) ps

run: ## Start the docker hub in attached mode (with logs)
	$(DOCKER_COMP) up

up: ## Start the docker hub in detached mode (no logs)
	$(DOCKER_COMP) up --detach

log: ## Show and follow tail of live logs
	$(DOCKER_COMP) logs --tail=20 --follow $(PHP_CONT_NAME)

down: ## Stop the docker hub
	$(DOCKER_COMP) down --remove-orphans

##—————— ꩜ PHP container ——————
php: ## Connect to the PHP FPM container
	$(PHP_CONT) fish

