package tag;

import java.sql.DriverManager;
import java.sql.SQLException;

public class Repository {

public static final String table = "tag";
String db_url;

public Repository(String db_file_path) {
    this.db_url = "jdbc:sqlite:" + db_file_path;
}

public void setup() throws SQLException {
    var sql = "CREATE TABLE " + table + "(" +
            "id INTEGER PRIMARY KEY," +
            "name TEXT NOT NULL" +
            ") strict";
    try (var c = DriverManager.getConnection(db_url);
         var s = c.prepareStatement(sql)) {
        s.execute();
    }
}

}
