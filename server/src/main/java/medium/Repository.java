package medium;

import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.List;

public class Repository {

    static final String table = "medium";
    String db_url;

    public Repository(String db_file_path) {
        this.db_url = "jdbc:sqlite:" + db_file_path;
    }

    public List<Medium> list() throws SQLException {
        var q = "SELECT * FROM " + table;
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(q)) {
            var rs = s.executeQuery();
            return Medium.listFromResultSet(rs);
        }
    }

    public Medium getById(int id) throws SQLException {
        var sql = "SELECT * FROM " + table + " WHERE id = " + id;
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            var rs = s.executeQuery();
            if (!rs.next()) return null;
            return Medium.fromResultSet(rs);
        }
    }

    public MediumStats getStats(int id) throws SQLException {
        var q = "SELECT m.id AS id, m.name AS name, m.kind AS kind, " +
                "sum(p.distance) AS distance, sum(p.moving_time) AS time FROM " +
                table + " m JOIN " + pursuit.Repository.table +
                " p ON p.medium_id = m.id where m.id = " + id;

        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(q)) {
            var rs = s.executeQuery();
            if (!rs.next()) return null;
            return MediumStats.fromResultSet(rs);
        }
    }

    public int insert(CreatePayload payload) throws SQLException {
        var sql = "INSERT INTO " + table + " (name, kind, created_at) VALUES (?, ?, ?)";
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            var i = 0;
            s.setString(++i, payload.name);
            s.setString(++i, payload.kind.toString());
            s.setLong(++i, System.currentTimeMillis() / 1000);

            var count = s.executeUpdate();
            if (count != 1) return 0;
            var generatedKeys = s.getGeneratedKeys();
            if (generatedKeys.next()) {
                return generatedKeys.getInt(1);
            }
            return 0;
        }
    }

}
