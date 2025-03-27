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
             var s = c.prepareStatement(params.buildQuery(select()))) {
            params.setArgs(s);
            var rs = s.executeQuery();
            var list = new ArrayList<ListItem>();
            while (rs.next()) {
                list.add(ListItem.fromResultSet(rs));
            }
            return list;
        }
    }

    public String select() {
        return "SELECT " + listItemFields + " FROM " + table;
    }
}
