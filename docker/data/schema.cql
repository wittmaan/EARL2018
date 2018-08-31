CREATE KEYSPACE IF NOT EXISTS density WITH replication = 
{
    'class': 'SimpleStrategy',
    'replication_factor': 1
}
AND DURABLE_WRITES = false;

CREATE TABLE IF NOT EXISTS density.points (
    zoom int,
    x int,
    y int,
    lat double,
    lng double,
    primary key ((zoom, x, y), lat, lng)
);