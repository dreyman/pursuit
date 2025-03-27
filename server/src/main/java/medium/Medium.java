package medium;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class Medium {
    public int id;
    public String kind;
    public String name;
    public int distance;
    public int time;
    public int created_at;
    public boolean archived;

    public static Medium fromResultSet(ResultSet rs) throws SQLException {
        var m = new Medium();
        m.id = rs.getInt("id");
        m.kind = rs.getString("kind");
        m.name = rs.getString("name");
        m.distance = rs.getInt("distance");
        m.time = rs.getInt("time");
        m.created_at = rs.getInt("created_at");
        m.archived = rs.getBoolean("archived");
        return m;
    }

    public static List<Medium> listFromResultSet(ResultSet rs) throws SQLException {
        var list = new ArrayList<Medium>();
        while (rs.next()) list.add(fromResultSet(rs));
        return list;
    }
}
