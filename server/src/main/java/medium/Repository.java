package medium;

import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class Repository {
    static final String table = "medium";
    String dbUrl;

    public Repository(String dbFilePath) {
        this.dbUrl = "jdbc:sqlite:" + dbFilePath;
    }

    public List<Medium> list(ListParams params) throws SQLException {
        try (var c = DriverManager.getConnection(dbUrl);
             var s = c.prepareStatement(params.buildQuery(select()))) {
            params.setArgs(s);
            var rs = s.executeQuery();
            var list = new ArrayList<Medium>();
            while (rs.next()) {
                list.add(Medium.fromResultSet(rs));
            }
            return list;
        }
    }

    public String select() {
        return "SELECT * FROM " + table;
    }
}
