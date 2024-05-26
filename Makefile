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
	$(EXECPG) bash

##@ Golang
tidy: ## Run go mod tidy
	$(EXECAPI) go mod tidy

lint: ## Run golangci-lint
	$(EXECAPI) golangci-lint run -v

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

##@ Dart
lint-dart: ## Run dart lint
	cd mobile && flutter analyze --suppress-analytics --no-fatal-infos

dart-build-runner: ## Run build_runner
	cd mobile && dart run build_runner build --delete-conflicting-outputs

dart-build-runner-watch: ## Run build_runner watch
	cd mobile && dart run build_runner watch --delete-conflicting-outputs

##@ Database
db-reset: db-drop db-create dma ## Reset the database

db-drop-dev: ## Drop the dev database (use only if db-create-migration fails)
	$(EXECPG) dropdb dev

db-create-migration: ## Create a new migration
	$(EXECPG) createdb dev
	$(EXECAPI) atlas migrate diff --env gorm
	$(EXECPG) dropdb dev

dcm: db-create-migration ## Alias for db-create-migration

db-migrate-apply: ## Apply the migrations
	$(EXECAPI) atlas migrate apply --dir "file://migrations" --url ${DB_URL} --allow-dirty

db-hash: ## Generate the hash for the migration
	$(EXECAPI) atlas migrate hash

dma: db-migrate-apply ## Alias for db-migrate-apply

db-drop: ## Drop the database
	$(EXECPG) dropdb ${DB_NAME}

db-create: ## Create the database
	$(EXECPG) createdb ${DB_NAME}

##@ Swagger
swagger: ## Generate swagger documentation
	$(EXECAPI) swag init --parseDependency --parseInternal

##@ CLI
collector: ## Collect the data from the API and store it in the database
	$(EXECAPI) go run main.go collector
