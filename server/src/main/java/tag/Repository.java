package tag;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class Repository {

public static final String table = "tag";
String db_url;

public Repository(String db_file_path) {
    this.db_url = "jdbc:sqlite:" + db_file_path;
}

public List<Tag> list() throws SQLException {
    var sql = "select * from " + table;
    try (var c = DriverManager.getConnection(db_url);
         var s = c.prepareStatement(sql)) {
        var rs = s.executeQuery();
        return Tag.listFromResultSet(rs);
    }
}

public Tag getByName(String name) throws SQLException {
    var sql = "select * from " + table + " where name = ?";
    try (var c = DriverManager.getConnection(db_url);
         var s = c.prepareStatement(sql)) {
        s.setString(1, name);
        var rs = s.executeQuery();
        if (!rs.next()) return null;
        return Tag.fromResultSet(rs);
    }
}

public int insert(String name) throws SQLException {
    var sql = util.Sql.insertOne(table, "name");
    try (var c = DriverManager.getConnection(db_url);
         var s = c.prepareStatement(sql)) {
        s.setString(1, name);
        var count = s.executeUpdate();
        if (count != 1) return 0;
        var generatedKeys = s.getGeneratedKeys();
        if (generatedKeys.next()) {
            return generatedKeys.getInt(1);
        }
        return 0;
    }
}

public void setup() throws SQLException {
    var sql = """
            create table %s (
            id integer primary key,
            name text not null unique
            ) strict""".formatted(table);
    try (var c = DriverManager.getConnection(db_url);
         var s = c.prepareStatement(sql)) {
        s.execute();
    }
}

}
