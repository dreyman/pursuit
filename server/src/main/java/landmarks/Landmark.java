package landmarks;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class Landmark {
    public int id;
    public String name;
    public float lat;
    public float lon;
    public int created_at;

    public static Landmark fromResultSet(ResultSet rs) throws SQLException {
        var lm = new Landmark();
        lm.id = rs.getInt("id");
        lm.name = rs.getString("name");
        lm.lat = rs.getFloat("lat");
        lm.lon = rs.getFloat("lon");
        lm.created_at = rs.getInt("created_at");
        return lm;
    }

    public static List<Landmark> listFromResultSet(ResultSet rs) throws SQLException {
        var list = new ArrayList<Landmark>();
        while (rs.next()) list.add(fromResultSet(rs));
        return list;
    }
}
