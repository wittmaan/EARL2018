package de.awi.cassandra;

import de.awi.commons.Constants;
import org.junit.Test;

import java.io.IOException;

/**
 * Class to import the route.csv data to Cassandra
 * <p>
 * Make sure Cassandra Docker is running!!
 */
public class TestImporter {

    @Test
    public void importRoute() throws IOException {
        for (int zoom = Constants.MIN_ZOOM_LEVEL; zoom <= Constants.MAX_ZOOM_LEVEL; zoom++) {
            try (Importer importer = new Importer(Constants.CASSANDRA_HOST, Constants.CASSANDRA_PORT, Constants.CASSANDRA_KEYSPACE,
                    "./src/test/resources/route.csv", 0, 1, zoom)) {
                importer.run(true);
            }
        }
    }
}
