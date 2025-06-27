# Yaci Address Balance Monitor

A lightweight Cardano address balance monitor based on [yaci-store]'s plugin system.

## Features

- Monitor balances of specified Cardano addresses.
- Supports two db storage systems: file-backed H2 (default) or PostgreSQL.
- Ready-to-use Docker images

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
| NETWORK                 | Cardano network (preview, preprod, mainnet)           | preprod                                       |
| START_SLOT              | (Optional) Start slot for syncing from a slot         |                                               |
| START_SLOT_BLOCK_HASH   | (Optional) Start syncing from a specific block hash   |                                               |
| ADDRESSES               | Whitespace-separated Cardano addresses to monitor     | addr_test1qzpe8r5u08uvnyv... addr_test1...    |
| YACI_STORE_PORT         | TCP port to expose yaci-store API                     | 8080                                          |
| YACI_STORE_DB_TYPE      | Database type (h2 or postgres)                        | h2                                            |
| YACI_STORE_DB_USER      | Database user (if using PostgreSQL)                   | yaci                                          |
| YACI_STORE_DB_PASSWORD  | Database password (if using PostgreSQL)               | dbpass                                        |
| YACI_STORE_DB_NAME      | Database name (if using PostgreSQL)                   | yaci_store                                    |

## Usage

### Local H2 Database (default)

To start the monitor using the default H2 backend you just need to run:

```sh
docker-compose up -d
```

### PostgreSQL Backend

To use a PostgreSQL backend, use the alternative Docker Compose file:

```sh
docker-compose -f docker-compose-postgres.yaml up -d
```

### Running with Plain Docker

You can also run the monitor directly using Docker without Compose, for simple setups or scripting:

```sh
docker run -it \
  -v $PWD/data/node-exporer:/data/node-exporter \
  -e ADDRESSES=addr_test1qzpe8r5u08uvnyvl58yumkspvsp43rnjg4yutlhem2q3dehmnlkg05ptkzz3ca85qt8uy9lhz92800c4nhag8zdvkq3swaxg38 \
  rcmorano/address-monitor
```

## Volumes and Persistence

- H2 database data: `./data/h2-data`
- PostgreSQL database data: `./data/pg-data`
- Node exporter data: `./data/node-exporter`. A [node-exporter] `textfile` collector compatible file will be written here.
- Additional config: `./config`
- Plugins: `./plugins`

[yaci-store]: https://github.com/bloxbean/yaci-store
[node-exporter]: https://github.com/prometheus/node_exporter?tab=readme-ov-file#textfile-collector
