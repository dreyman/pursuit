package pursuit;

import com.google.gson.annotations.SerializedName;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

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

    public int start_time;
    public int finish_time;
    public float start_lat;
    public float start_lon;
    public float finish_lat;
    public float finish_lon;
    public int distance;
    public int total_time;
    public int moving_time;
    public int stops_count;
    public int stops_duration;
    public int untracked_distance;
    public int avg_speed;
    public int avg_travel_speed;
    public float westernmost_lat;
    public float westernmost_lon;
    public float northernmost_lat;
    public float northernmost_lon;
    public float easternmost_lat;
    public float easternmost_lon;
    public float southernmost_lat;
    public float southernmost_lon;
    public int size;

    public static Pursuit fromResultSet(ResultSet rs) throws SQLException {
        var p = new Pursuit();
        p.id = rs.getInt("id");
        p.name = rs.getString("name");
        p.description = rs.getString("description");
        p.kind = Pursuit.Kind.values()[rs.getInt("kind")];
        p.start_time = rs.getInt("start_time");
        p.finish_time = rs.getInt("finish_time");
        p.start_lat = rs.getFloat("start_lat");
        p.start_lon = rs.getFloat("start_lon");
        p.finish_lat = rs.getFloat("finish_lat");
        p.finish_lon = rs.getFloat("finish_lon");
        p.distance = rs.getInt("distance");
        p.total_time = rs.getInt("total_time");
        p.moving_time = rs.getInt("moving_time");
        p.stops_count = rs.getInt("stops_count");
        p.stops_duration = rs.getInt("stops_duration");
        p.untracked_distance = rs.getInt("untracked_distance");
        p.avg_speed = rs.getInt("avg_speed");
        p.avg_travel_speed = rs.getInt("avg_travel_speed");
        p.westernmost_lat = rs.getFloat("westernmost_lat");
        p.westernmost_lon = rs.getFloat("westernmost_lon");
        p.northernmost_lat = rs.getFloat("northernmost_lat");
        p.northernmost_lon = rs.getFloat("northernmost_lon");
        p.easternmost_lat = rs.getFloat("easternmost_lat");
        p.easternmost_lon = rs.getFloat("easternmost_lon");
        p.southernmost_lat = rs.getFloat("southernmost_lat");
        p.southernmost_lon = rs.getFloat("southernmost_lon");
        p.size = rs.getInt("size");
        return p;
    }

    public static List<Pursuit> listFromResultSet(ResultSet rs) throws SQLException {
        var list = new ArrayList<Pursuit>();
        while (rs.next()) list.add(fromResultSet(rs));
        return list;
    }
}
