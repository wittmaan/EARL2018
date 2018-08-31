
## EARL 2018 - Visualizing Huge Amounts of Fleet Data using Shiny and Leaflet

This repo contains all code needed to reproduce the shown results of my talk 
at the EARL conference 2018 in london.

### Docker

- Run *docker-compose up* in the docker folder to start cassandra 
- Create keyspace using *docker exec -it cassandra0 cqlsh -f /data/schema.cql*
- Jump into the docker container with *docker exec -it cassandra0 /bin/bash*

### Data

- Some random gps data points in and around munich were created, find them in src\main\R\App1\data\
- Import the data into cassandra using the *importRoute()* methode in src\test\java\de\awi\cassandra

### Apps

- App1: implementation using only shiny and leaflet, start it using "library(shiny); runApp("App1")"
- App2: tile layer based approach:
    - start TileProvider API using *startApi.R*
    - start Http Server using *startHttpServer.R*
    - runApp("App2")

### Links

- Go implementation: https://github.com/fogleman/density
