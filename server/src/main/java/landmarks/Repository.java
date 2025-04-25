package landmarks;

import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.List;

public class Repository {
    public static final String table = "landmark";
    String db_url;

    public Repository(String db_file_path) {
        this.db_url = "jdbc:sqlite:" + db_file_path;
    }

    public List<Landmark> list() throws SQLException {
        var sql = "SELECT * FROM " + table;
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            var rs = s.executeQuery();
            return Landmark.listFromResultSet(rs);
        }
    }

    public Landmark getById(int id) throws SQLException {
        var sql = "SELECT * FROM " + table + " WHERE id = ?";
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            s.setInt(1, id);
            var rs = s.executeQuery();
            if (!rs.next()) return null;
            return Landmark.fromResultSet(rs);
        }
    }

    public int insert(Landmark lm) throws SQLException {
        var sql = "INSERT INTO " + table + " (name, lat, lon, created_at) " + "VALUES (?, ?, ?, ?)";
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            var i = 0;
            s.setString(++i, lm.name);
            s.setFloat(++i, lm.lat);
            s.setFloat(++i, lm.lon);
            s.setInt(++i, lm.created_at);

            var count = s.executeUpdate();
            if (count != 1) return 0;
            var generatedKeys = s.getGeneratedKeys();
            if (generatedKeys.next()) {
                return generatedKeys.getInt(1);
            }
            return 0;
        }
    }

    public boolean delete(int id) throws SQLException {
        var sql = "DELETE FROM " + table + " WHERE id = ?";
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            s.setInt(1, id);
            var count = s.executeUpdate();
            return count == 1;
        }
    }

    public void setup() throws SQLException {
        var sql = "CREATE TABLE " + table + "(" +
                "id INTEGER PRIMARY KEY," +
                "name TEXT NOT NULL," +
                "lat REAL NOT NULL," +
                "lon REAL NOT NULL," +
                "created_at INTEGER NOT NULL" +
                ") strict";
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            s.execute();
        }
    }
}
