package pursuit;

import db.StrictSqlite;
import db.jdbc.Sqlite;

import java.lang.reflect.Field;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class Repository {

public static final String table = "pursuit";
StrictSqlite db;
String db_url;
String summary_fields;

public Repository(String db_file_path) {
    this.db = new Sqlite(db_file_path);
    this.db_url = "jdbc:sqlite:" + db_file_path;
    this.summary_fields = Arrays.stream(Summary.class.getFields())
            .map(Field::getName)
            .collect(Collectors.joining(", "));
}

public List<Summary> list(Query params) throws SQLException {
    String sql = "SELECT " + summary_fields + " FROM " + table +
            " " + params.buildSql();
    try (var c = DriverManager.getConnection(db_url);
         var s = c.prepareStatement(sql)) {
        var rs = s.executeQuery();
        return Summary.listFromResultSet(rs);
    }
}

public Pursuit getById(int id) throws SQLException {
    var sql = "SELECT * FROM " + table + " WHERE id = ?";
    try (var c = DriverManager.getConnection(db_url);
         var s = c.prepareStatement(sql)) {
        s.setInt(1, id);
        var rs = s.executeQuery();
        if (!rs.next()) return null;
        return Pursuit.fromResultSet(rs);
    }
}

public int update(int id, UpdatePayload payload) throws SQLException {
    var sql = payload.buildSql(table);
    assert sql != null;

    try (var c = DriverManager.getConnection(db_url);
         var s = c.prepareStatement(sql)) {
        payload.setArgs(id, s);
        return s.executeUpdate();
    }
}

}
