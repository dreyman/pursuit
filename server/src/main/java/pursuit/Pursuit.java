package pursuit;

import stats.Stats;

import java.sql.ResultSet;
import java.sql.SQLException;

public class Pursuit {
    public enum Kind {
        cycling,
        running,
        walking,
        hiking,
        unknown
    }

    public int id;
    public String name;
    public String description;
    public Kind kind;
    public Integer medium_id;
    public Stats stats;

    public static Pursuit fromResultSet(ResultSet rs) throws SQLException {
        var p = new Pursuit();
        p.id = rs.getInt("id");
        p.name = rs.getString("name");
        p.description = rs.getString("description");
        p.kind = Pursuit.Kind.values()[rs.getInt("kind")];
        p.medium_id = rs.getInt("medium_id");
        if (rs.wasNull()) p.medium_id = null;
        p.stats = Stats.fromResultSet(rs);
        return p;
    }
}
