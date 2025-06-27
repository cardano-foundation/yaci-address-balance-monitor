# Yaci Address Balance Monitor

A lightweight Cardano address balance monitor with multiple storage backends, supporting both H2 and PostgreSQL.

## Features

- Monitor balances of specified Cardano addresses.
- Flexible storage: H2 (default) or PostgreSQL.
- Easy configuration via `.env` file.
- Ready-to-use Docker configurations.

## Requirements

- Docker and Docker Compose installed
- (Optional) PostgreSQL for advanced deployments

## Configuration

Copy the template to `.env` and adjust variables as needed:

```sh
cp .env.example .env
```

`.env` variables:

| Variable                | Description                                           | Example Value                                 |
|-------------------------|-------------------------------------------------------|-----------------------------------------------|
| YACI_STORE_PORT         | Port for the service                                  | 8080                                          |
| NETWORK                 | Cardano network (preprod, mainnet, etc)               | preprod                                       |
| START_SLOT              | (Optional) Start slot for syncing from a slot         |                                               |
| START_SLOT_BLOCK_HASH   | (Optional) Start syncing from a specific block hash   |                                               |
| ADDRESS                 | Cardano address to monitor                            | addr_test1qzpe8r5u08uvnyv...                  |

## Usage

### Local H2 Database (default)

To start the monitor using the default H2 backend:

```sh
docker-compose up -d
```

This will:

- Build and run the monitor on the port specified in `.env` (`YACI_STORE_PORT`, default: 8080).
- Mount `./data/h2-data` for H2 storage persistence.
- Mount additional config and plugins folders.

### PostgreSQL Backend

To use a PostgreSQL backend, use the alternative Docker Compose file:

```sh
docker-compose -f docker-compose-postgres.yaml up -d
```

This will:

- Start a dedicated PostgreSQL container (as defined by `docker-compose-postgres.yaml`).
- Start the monitor with environment variables for PostgreSQL:
  - `YACI_STORE_DB_TYPE=postgres`
  - `YACI_STORE_DB_HOST=yaci-store-postgres`
  - `YACI_STORE_DB_PORT=5432`
  - `YACI_STORE_DB_USER=yaci`
  - `YACI_STORE_DB_PASSWORD=dbpass`
  - `YACI_STORE_DB_NAME=yaci_store`

**Note:** You may need to ensure that `docker-compose-postgres.yaml` exists and is configured as required.

### Running with Plain Docker

You can also run the monitor directly using Docker without Compose, for simple setups or scripting:

```sh
docker run -it \
  -v $PWD/data/node-exporer:/data/node-exporter \
  -e ADDRESSES=addr_test1qzpe8r5u08uvnyvl58yumkspvsp43rnjg4yutlhem2q3dehmnlkg05ptkzz3ca85qt8uy9lhz92800c4nhag8zdvkq3swaxg38 \
  rcmorano/address-monitor
```

Change the `ADDRESSES` environment variable to the Cardano address you want to monitor.

## Volumes and Persistence

- H2 database data: `./data/h2-data`
- Node exporter data: `./data/node-exporter`
- Additional config: `./config`
- Plugins: `./plugins`

Ensure these directories exist for Docker to mount them as volumes.

## Logging

The service uses Docker's `json-file` logging driver, with a max size of 100MB and up to 5 log files.

## Customization

- Edit `.env` to change address, network, or monitoring parameters.
- Edit docker-compose files to adjust service parameters or add more services.

## License

[Specify your license here]

---

**For more details, see the individual configuration files:**
- [.env.example](./.env.example)
- [docker-compose.yaml](./docker-compose.yaml)
- [docker-compose-postgres.yaml](./docker-compose-postgres.yaml)
