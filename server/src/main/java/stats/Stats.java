package stats;

import java.sql.ResultSet;
import java.sql.SQLException;

public class Stats {
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

    public static Stats fromResultSet(ResultSet rs) throws SQLException {
        var s = new Stats();
        s.start_time = rs.getInt("start_time");
        s.finish_time = rs.getInt("finish_time");
        s.start_lat = rs.getFloat("start_lat");
        s.start_lon = rs.getFloat("start_lon");
        s.finish_lat = rs.getFloat("finish_lat");
        s.finish_lon = rs.getFloat("finish_lon");
        s.distance = rs.getInt("distance");
        s.total_time = rs.getInt("total_time");
        s.moving_time = rs.getInt("moving_time");
        s.stops_count = rs.getInt("stops_count");
        s.stops_duration = rs.getInt("stops_duration");
        s.untracked_distance = rs.getInt("untracked_distance");
        s.avg_speed = rs.getInt("avg_speed");
        s.avg_travel_speed = rs.getInt("avg_travel_speed");
        s.westernmost_lat = rs.getFloat("westernmost_lat");
        s.westernmost_lon = rs.getFloat("westernmost_lon");
        s.northernmost_lat = rs.getFloat("northernmost_lat");
        s.northernmost_lon = rs.getFloat("northernmost_lon");
        s.easternmost_lat = rs.getFloat("easternmost_lat");
        s.easternmost_lon = rs.getFloat("easternmost_lon");
        s.southernmost_lat = rs.getFloat("southernmost_lat");
        s.southernmost_lon = rs.getFloat("southernmost_lon");
        s.size = rs.getInt("size");
        return s;
    }
}
