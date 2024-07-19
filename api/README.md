# API

This is the API for the project.

## Content

- [API](#api)
  - [Content](#content)
  - [Prerequisites](#prerequisites)
  - [Getting Started](#getting-started)
    - [Using Docker](#using-docker)
    - [Without Docker](#without-docker)
    - [Migrations](#migrations)
    - [Collector](#collector)
    - [Running unit tests](#running-unit-tests)
  - [Building the API](#building-the-api)
    - [Development Environment](#development-environment)
    - [Production Environment](#production-environment)

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) or [Go](https://golang.org/doc/install)
- [Firebase](https://firebase.google.com/docs/web/setup)
- [PostgreSQL](https://www.postgresql.org/download/)

## Getting Started

To run the API, you will primarily need Docker installed. If you prefer to run the API without Docker, ensure you have Go installed on your system.

You will also need a Firebase project. Refer to the [Firebase documentation](https://firebase.google.com/docs/admin/setup?hl=fr#set-up-project-and-service-account) to create a new project.

### Using Docker

If you have Docker and Docker Compose installed, refer to the [installation guide](../README.md#installation) to launch the API easily. Otherwise, follow the instructions below.

### Without Docker

1. **Environment Variables:**

   Specify the required environment variables in the [`.env`](../.env) file. You can override the default values using a `.env.local` file.

   > **Note:**  
   > The API does not utilize any configuration manager like [Viper](https://github.com/spf13/viper), relying instead on environment variables injected by Docker.

   To run the API without Docker, manually specify the environment variables from the [`.env`](../.env) file. For example:

   ```bash
   API_ENV=development go run main.go
   ```

2. **PostgreSQL Database:**

   The API uses a PostgreSQL database, so you need to have a running PostgreSQL server to use it.

### Migrations

To create the database schema, run the following command:

```bash
docker run --rm -v $(PWD)/api/migrations:/migrations --network <database-network> arigaio/atlas migrate apply --dir "file://migrations" --url ${DB_URL} --allow-dirty
```

If your database is running in a Docker container, you can use the same network as the database container. Replace `<database-network>` with the network name of the database container.

### Collector

To load the data from the Helldivers API, run the following command:

```bash
go run main.go collector
```

### Running unit tests

To run the unit tests, execute the following command:

```bash
go test ./...
```

## Building the API

### Development Environment

1. **Build the API Image:**

   ```bash
   docker build -t helldivers-dev-api -f docker/dev/golang/Dockerfile .
   ```

2. **Run the API Container:**

   ```bash
   docker run -d -p 5000:5000 -v ${PWD}/api:/usr/src/app --env-file .env helldivers-dev-api
   ```

### Production Environment

1. **Build the API Image:**

   ```bash
   docker build -t helldivers-prod-api -f docker/prod/golang/Dockerfile .
   ```

2. **Run the API Container:**

   ```bash
   docker run -d -p 5000:5000 --env-file .env helldivers-prod-api
   ```

   Specify the environment variables in the [`.env`](../.env) file for the production environment:

   ```plaintext
   API_ENV=production
   ```
