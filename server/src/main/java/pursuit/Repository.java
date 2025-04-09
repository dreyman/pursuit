package pursuit;

import pursuit.sqlite.UpdateQuery;

import java.lang.reflect.Field;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class Repository {

    public static final String table = "pursuit";
    String db_url;
    String list_item_fields;

    public Repository(String db_file_path) {
        this.db_url = "jdbc:sqlite:" + db_file_path;
        this.list_item_fields = Arrays.stream(ListItem.class.getFields())
                .map(Field::getName)
                .collect(Collectors.joining(", "));
    }

    public List<ListItem> list(QueryParams params) throws SQLException {
        String sql = "SELECT " + list_item_fields + " FROM " + table +
                " " + params.buildSql();
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            var rs = s.executeQuery();
            return ListItem.listFromResultSet(rs);
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
        var update = new UpdateQuery(id, payload);
        var sql = update.buildSql(table);
        assert sql != null;

        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            update.setArgs(s);
            return s.executeUpdate();
        }
    }
}
