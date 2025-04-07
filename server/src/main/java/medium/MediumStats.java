package medium;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class MediumStats {
    public int id;
    public Medium.Kind kind;
    public String name;
    public int distance;
    public int time;
    public List<pursuit.ListItem> last_pursuits;

    public MediumStats() {
        last_pursuits = List.of();
    }

    public static MediumStats fromResultSet(ResultSet rs) throws SQLException {
        var m = new MediumStats();
        m.id = rs.getInt("id");
        m.kind = Medium.Kind.valueOf(rs.getString("kind"));
        m.name = rs.getString("name");
        m.distance = rs.getInt("distance");
        m.time = rs.getInt("time");
        return m;
    }
}
