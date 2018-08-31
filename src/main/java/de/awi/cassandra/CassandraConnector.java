package de.awi.cassandra;

import com.datastax.driver.core.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Connector to Cassandra-DB
 *
 * @see http://www.baeldung.com/cassandra-with-java
 */
@SuppressWarnings("JavadocReference")
class CassandraConnector implements AutoCloseable {

    private final Logger log = LogManager.getLogger(CassandraConnector.class.getName());
    private final Cluster cluster;
    private final Session session;

    public CassandraConnector(String host, Integer port, String keyspace) {
        this.cluster = Cluster.builder()
                .addContactPoint(host).withPort(port)
                .withSocketOptions(new SocketOptions().setReadTimeoutMillis(60_000))
                .build();
        this.session = cluster.connect(keyspace);
        log.info("Connection created: host=" + host + ", port=" + port + ", keyspace=" + keyspace);
    }

    public Session getSession() {
        return session;
    }

    @Override
    public void close() {
        session.close();
        cluster.close();
        log.info("Connection closed");
    }
}
