package de.awi.cassandra;

import com.datastax.driver.core.BoundStatement;
import com.datastax.driver.core.PreparedStatement;
import de.awi.commons.Util;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Random;

/**
 * Importer Class to insert gps-data from a csv file to Cassandra
 */

class Importer implements AutoCloseable {

    private final Logger log = LogManager.getLogger(Importer.class.getName());

    private final int latIndex;
    private final int lonIndex;
    private final int zoom;

    private final File file;
    private final CassandraConnector connector;
    private final PreparedStatement statement;
    private final Random random;

    /**
     * Constructor
     *
     * @param host     cassandra host
     * @param port     cassandra port
     * @param keyspace keyspace to use
     * @param filename filename to read from
     * @param latIndex index of the latitude column
     * @param lonIndex index of the longitude column
     * @param zoom     zoom
     */
    public Importer(String host, Integer port, String keyspace, String filename, int latIndex, int lonIndex, int zoom) {
        this.latIndex = latIndex;
        this.lonIndex = lonIndex;
        this.zoom = zoom;

        this.file = new File(filename.trim());
        this.connector = new CassandraConnector(host, port, keyspace);
        log.info("Created Importer: filename=" + filename + ", latIndex=" + latIndex + ", lonIndex=" + lonIndex + ", zoom=" + zoom);

        this.statement = connector.getSession().prepare("INSERT INTO density.points (zoom, x, y, lat, lng) VALUES (?, ?, ?, ?, ?)");
        random = new Random(42);
    }

    /**
     * run the import
     *
     * @param augment do data augmentation on the given data
     * @throws IOException exception
     */
    public void run(Boolean augment) throws IOException {
        long lineCount = 0;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            br.readLine(); // skip header

            String line;
            while ((line = br.readLine()) != null && !line.isEmpty()) {
                lineCount++;

                if (lineCount % 100_000 == 0)
                    log.info("Line " + lineCount);

                String[] fields = line.split(",");

                if (augment) {
                    for (int i = 0; i < 1000; i++) {
                        double lat = Double.parseDouble(fields[latIndex]);
                        double lon = Double.parseDouble(fields[lonIndex]);

                        lat = lat + random.nextGaussian() / 10_000;
                        lon = lon + random.nextGaussian() / 10_000;
                        execute(lat, lon);
                    }
                } else {
                    double lat = Double.parseDouble(fields[latIndex]);
                    double lon = Double.parseDouble(fields[lonIndex]);
                    execute(lat, lon);
                }
            }
        }
    }

    private void execute(double lat, double lon) {
        int[] tile = Util.calcTile(zoom, lat, lon);
        BoundStatement bind = statement.bind(zoom, tile[0], tile[1], lat, lon);
        connector.getSession().executeAsync(bind);
    }

    @Override
    public void close() {
        connector.close();
    }
}
