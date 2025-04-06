package medium;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class Medium {
    public enum Kind { bike, shoes }

    public int id;
    public Kind kind;
    public String name;
    public int created_at;

    public static Medium fromResultSet(ResultSet rs) throws SQLException {
        var m = new Medium();
        m.id = rs.getInt("id");
        m.kind = Medium.Kind.valueOf(rs.getString("kind"));
        m.name = rs.getString("name");
        m.created_at = rs.getInt("created_at");
        return m;
    }

    public static List<Medium> listFromResultSet(ResultSet rs) throws SQLException {
        var list = new ArrayList<Medium>();
        while (rs.next()) list.add(fromResultSet(rs));
        return list;
    }
}
