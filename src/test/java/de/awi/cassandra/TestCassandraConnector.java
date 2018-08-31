package de.awi.cassandra;

import com.datastax.driver.core.ResultSet;
import de.awi.commons.Constants;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

/**
 * Class to test CassandraConnector class
 * <p>
 * Make sure TestImporter is run before!!
 */
public class TestCassandraConnector {

    @Test
    public void testConnection() {
        try (CassandraConnector connector = new CassandraConnector(Constants.CASSANDRA_HOST, Constants.CASSANDRA_PORT, Constants.CASSANDRA_KEYSPACE)) {
            ResultSet resultSet = connector.getSession().execute("select * from points limit 10");
            int count = 0;
            while (resultSet.iterator().hasNext()) {
                resultSet.iterator().next();
                count += 1;
            }
            assertEquals(10, count);
        }
    }
}
