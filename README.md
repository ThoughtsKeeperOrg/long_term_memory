# Long term memory (ltm)

App serves as backend layer which handles request from UI, stores received data and files, coordinates work of other backend services by communication via kafka messages. 

Postgresql, Neo4j databases are used.

### Configuration

ENV

```
SECRET_KEY_BASE = long_string
PORT = 3009
DB_HOST = db
DB_PORT = 5432
DB_NAME = ltm
DB_USERNAME = postgres
DB_PASSWORD = postgres
LTM_STORAGE_PATH = '/ltm'
KAFKA_CLIENT_ID = ltm
KAFKA_SOCKET = kafka-broker:9093
NEO4J_HOST=neo4j
NEO4J_PORT=7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your_password
NEO4J_DB=neo4j
```


### Testing

```
rspec spec/
```

### Running

```
rails s
```

Kafka consumer mode:
```
bundle exec karafka server
```

### Docker compose

example can be found [here](https://github.com/ThoughtsKeeperOrg/ops/blob/main/docker-compose.yml)