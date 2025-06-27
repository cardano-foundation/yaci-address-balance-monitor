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
| ADDRESSES               | Whitespace-separated Cardano addresses to monitor     | addr_test1qzpe8r5u08uvnyv... addr_test1...    |
| NETWORK                 | Cardano network (preview, preprod, mainnet)           | preprod                                       |
| CARDANO_HOST            | Cardano relay to be used (via n2n)                    | relay.preprod.staging.wingriders.com          |
| CARDANO_PORT            | Cardano relay port                                    | 3001                                          |
| START_SLOT              | (Optional) Start slot for syncing from a slot         | 83462356                                      |
| START_SLOT_BLOCK_HASH   | (Optional) Start syncing from a specific block hash   | df36d0c8728a359198eaffa18fc82a9d3970f0f5893042dddd0b56fa457c2dd6 |
| YACI_STORE_PORT         | TCP port to expose yaci-store API                     | 8080                                          |
| YACI_STORE_DB_TYPE      | Database type (h2 or postgres)                        | h2                                            |
| YACI_STORE_DB_USER      | Database user (if using PostgreSQL)                   | yaci                                          |
| YACI_STORE_DB_PASSWORD  | Database password (if using PostgreSQL)               | dbpass                                        |
| YACI_STORE_DB_NAME      | Database name (if using PostgreSQL)                   | yaci_store                                    |

## Running

### Using H2 file-backed storage (default)

To start the monitor using the default H2 backend you just need to run:

```sh
docker-compose up -d
```

### Using postgres storage (default)

To use a PostgreSQL backend, use the alternative Docker Compose file:

```sh
docker-compose -f docker-compose-postgres.yaml up -d
```

### Using plain docker

You can also run the monitor directly using Docker without Compose, for simple setups or scripting:

```sh
docker run -it \
  -v $PWD/data/node-exporer:/data/node-exporter \
  -e NETWORK=preprod \
  -e ADDRESSES=addr_test1qzpe8r5u08uvnyvl58yumkspvsp43rnjg4yutlhem2q3dehmnlkg05ptkzz3ca85qt8uy9lhz92800c4nhag8zdvkq3swaxg38 \
  cardanofoundation/yaci-address-balance-monitor:latest
```

## Gathering balances

A [node-exporter] `textfile` collector compatible file will be written in the `./data/node-exporter` directory, and serving it via node-exporter is the original idea behing this service so you can build your own grafana dashboard and setup alerts. But you could also:

* Read the `textfile` directly:
```
cat ./data/node-exporter/utxo-balances
```
* Get updates from service logs:
```
docker compose logs -f yaci-address-balance-monitor | grep YABM
```
* Access yaci-store API directly to retrieve utxos and add them yourself:
```
curl localhost:8080/api/v1/addresses/addr_test1wr4se9nuh57rnwu350mzy7ltztnhekpptmpdkzwupaj49nqkldg8j/utxos
```
* Or, if using postgres (h2 is a bit trickier), querying directly the database:
```
docker compose -f docker-compose-postgres.yaml \
  exec -it \
  yaci-store-postgres \
  bash -c 'PGDATABASE=$POSTGRES_DB PGUSER=$POSTGRES_USER PGPASSWORD=$POSTGRES_PASS psql -c "SELECT owner_addr, SUM(lovelace_amount) AS total FROM address_utxo GROUP BY owner_addr"'
```

## Volumes and Persistence

- H2 database data: `./data/h2-data`
- PostgreSQL database data: `./data/pg-data`
- Node exporter data: `./data/node-exporter`.
- Additional config: `./config`
- Plugins: `./plugins`

[yaci-store]: https://github.com/bloxbean/yaci-store
[node-exporter]: https://github.com/prometheus/node_exporter?tab=readme-ov-file#textfile-collector
