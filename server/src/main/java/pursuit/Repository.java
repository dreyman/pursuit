package pursuit;

import java.lang.reflect.Field;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class Repository {
    static final String table = "pursuit";

    String dbUrl;
    String listItemFields;

    public Repository(String dbFilePath) {
        this.dbUrl = "jdbc:sqlite:" + dbFilePath;
        this.listItemFields = Arrays.stream(ListItem.class.getFields())
                .map(Field::getName)
                .collect(Collectors.joining(", "));
    }

    public List<ListItem> list(ListParams params) throws SQLException {
        try (var c = DriverManager.getConnection(dbUrl);
             var s = c.prepareStatement(params.buildQuery(selectFields(listItemFields)))) {
            params.setArgs(s);
            var rs = s.executeQuery();
            var list = new ArrayList<ListItem>();
            while (rs.next()) {
                list.add(ListItem.fromResultSet(rs));
            }
            return list;
        }
    }

    public Pursuit getById(int id) throws SQLException{
        try (var c = DriverManager.getConnection(dbUrl);
             var s = c.prepareStatement(selectById())) {
            s.setInt(1, id);
            var rs = s.executeQuery();
            if (!rs.next()) return null;
            return Pursuit.fromResultSet(rs);
        }
    }

    public int update(UpdatePayload payload) throws SQLException {
        var q = payload.buildQuery(updateQuery());
        if (q == null) return 0;
        try (var c = DriverManager.getConnection(dbUrl);
             var s = c.prepareStatement(q)) {
            payload.setArgs(s);
            return s.executeUpdate();
        }
    }

    String selectFields(String fields) {
        return "SELECT " + fields + " FROM " + table;
    }

    String selectById() {
        return "SELECT * FROM " + table + " WHERE id = ?";
    }

    String updateQuery() {
        return "UPDATE " + table;
    }
}
