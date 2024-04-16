include .env

.DEFAULT_GOAL:=help
PWD=$(shell pwd)
COMPOSE=docker compose
EXECAPI=$(COMPOSE) exec api
EXECPG=$(COMPOSE) exec postgres

## All commands available in the Makefile

##@ Helper
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nAll commands available in the Makefile\n \nUsage:\n  make \033[36m<target>\033[0m\n"} /^[.a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Starting/stopping the project

start: build up-recreate ## Build and start containers project 

build: ## Build containers project
	$(COMPOSE) build --force-rm

up: ## Start the project
	$(COMPOSE) up -d --remove-orphans

up-recreate: ## Start the project and recreate the containers
	$(COMPOSE) up -d --remove-orphans --force-recreate

stop: ## Stop containers project
	$(COMPOSE) stop

down: ## Stop and remove containers project
	$(COMPOSE) down

restart: ## Restart containers project
	$(COMPOSE) restart

##@ SSH
ssh: ## SSH into the next container
	$(EXECAPI) sh

ssh-pg: ## SSH into the postgres container
	$(EXECPG) sh

##@ Containers
list-containers: ## List all containers
	docker compose ps -a

##@ Logs
logs: ## Show logs
	$(COMPOSE) logs

logs-api: ## Show logs for the next container
	$(COMPOSE) logs --since 1m -f api

logs-pg: ## Show logs for the postgres container
	$(COMPOSE) logs postgres

##@ Database
db-reset: db-drop db-create dma ## Reset the database

db-create-migration: ## Create a new migration
  # Drop database first to avoid conflicts if there was an error in the previous execution command
	$(EXECPG) dropdb dev
	$(EXECPG) createdb dev 
	$(EXECAPI) atlas migrate diff --env gorm
	$(EXECPG) dropdb dev

dcm: db-create-migration ## Alias for db-create-migration

db-migrate-apply: ## Apply the migrations
	$(EXECAPI) atlas migrate apply --url ${DB_URL}

dma: db-migrate-apply ## Alias for db-migrate-apply

db-drop: ## Drop the database
	$(EXECPG) dropdb ${DB_NAME}

db-create: ## Create the database
	$(EXECPG) createdb ${DB_NAME}
