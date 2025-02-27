package fields.wild.storage;

import java.sql.DriverManager;
import java.sql.SQLException;

public class SqliteStorage implements Storage {

    private final String dbUrl;

    public SqliteStorage(String dbFilePath) {
        this.dbUrl = "jdbc:sqlite:" + dbFilePath;
    }

//    public String test(int id) throws SQLException {
//        var conn = DriverManager.getConnection(dbUrl);
//        var stmt = conn.prepareStatement("SELECT name FROM test WHERE id = ?");
//        stmt.setInt(1, id);
//        var rs = stmt.executeQuery();
//        if (!rs.next()) return null;
//        return rs.getString("name");
//    }

    // TODO
    public void init() throws SQLException {
        var conn = DriverManager.getConnection(dbUrl);
        var stmt = conn.createStatement();
        stmt.executeQuery(create_entries_table_sql);
    }

    static String create_entries_table_sql = """
                CREATE TABLE IF NOT EXISTS entries (
                    timestamp INTEGER PRIMARY KEY,
                    distance INTEGER NOT NULL,
                    total_time INTEGER NOT NULL,,
                    moving_time INTEGER NOT NULL,,
                    pauses_count INTEGER NOT NULL,,
                    pauses_len INTEGER NOT NULL,,
                    untracked_distance INTEGER NOT NULL,
                );
            """;
}
