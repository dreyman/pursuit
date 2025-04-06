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
}
