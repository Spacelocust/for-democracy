# For-democracy

## Content

-   [For democracy](#for-democracy)
    -   [Prerequisites](#prerequisites)
    -   [Content](#content)
    -   [Installation](#installation)
    -   [Services](#services)
    -   [Commands](#commands)
    -   [Swagger](#Swagger)
    -   [How to use Gorm with Atlas](/api/docs/how-to-use-gorm-atlas.md)

## Prerequisites

-   [Flutter](https://flutter.dev/docs/get-started/install)
-   [Android Studio](https://developer.android.com/studio) or Android SDK
-   [Docker](https://www.docker.com/get-started)
-   [Docker Compose](https://docs.docker.com/compose/install/)
-   [GNU Make](https://www.gnu.org/software/make/)

## Installation

> [!NOTE]  
> The Docker containers are used to run the API and the database. You will have to run the flutter mobile and wep app separately on your local machine.

1. Clone the repository
2. (Optional) Add `compose.override.yml` to override the default compose configuration
3. Run `make start`
4. Run `make db-fixtures` to load the database with fixtures (under development)
5. Go to [http://localhost:5000](http://localhost:5000) to access Golang API

After the first run, you can use `make stop` & `make up` to quickly stop and start the containers.
All the available commands are listed in the `Makefile`, you can use `make` or `make help` to list them all. Read the [commands section](#commands) for more information.

if you want to reset the database, you can use `make db-reset` it will remove the database and create a new one and load migrations, you will have to run `make db-fixtures` again to load the database with fixtures.

## Services

All the services used by the project.

> [!NOTE]  
> Some services are only available in dev. They will never be used in production or even test environments.

| Service name | Host             | Aliases                | Ports | Description                                              |
| ------------ | ---------------- | ---------------------- | ----- | -------------------------------------------------------- |
| `api`        | `localhost:5000` | `fd-api`               |       | The Golang API                                           |
| `postgres`   |                  | `fd-postgres`          |       | The database used by the API.                            |
| `adminer`    | `localhost:8080` | `fd-adminer`           |       | Used to manage PostgreSQL easily. Only available in dev. | 

## Authentication

We use simple username/password for development purposes.

| Service               | Username | Password |
| --------------------- | -------- | -------- |
| `adminer`, `postgres` | `root`   | `root`   |

## Commands

> [!NOTE]  
> All the commands are available in the `Makefile`. You can use `make` or `make help` to list all the available commands.
> If you want to add a new command, please add it to the `Makefile` and document it here.

## Swagger
The API is documented using Swagger. You can access the documentation by going to [http://localhost:5000/swagger/index.html](http://localhost:5000/swagger/index.html).