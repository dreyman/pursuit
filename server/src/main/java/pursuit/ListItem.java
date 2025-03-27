package pursuit;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ListItem {
    public int id;
    public String name;
    public Pursuit.Kind kind;

    public int start_time;
    public int distance;
    public int total_time;
    public int moving_time;
    public int avg_speed;
    public int avg_travel_speed;

    public static ListItem fromResultSet(ResultSet rs) throws SQLException {
        var item = new ListItem();
        item.id = rs.getInt("id");
        item.name = rs.getString("name");
        item.kind = Pursuit.Kind.values()[rs.getInt("kind")];
        item.start_time = rs.getInt("start_time");
        item.distance = rs.getInt("distance");
        item.total_time = rs.getInt("total_time");
        item.moving_time = rs.getInt("moving_time");
        item.avg_speed = rs.getInt("avg_speed");
        item.avg_travel_speed = rs.getInt("avg_travel_speed");
        return item;
    }

    public static List<ListItem> listFromResultSet(ResultSet rs) throws SQLException {
        var list = new ArrayList<ListItem>();
        while (rs.next()) list.add(fromResultSet(rs));
        return list;
    }
}
