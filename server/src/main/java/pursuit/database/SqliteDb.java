package pursuit.database;

import pursuit.Database;
import pursuit.model.Bike;
import pursuit.model.Route;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

public class SqliteDb implements Database {

    private final String dbUrl;

    public SqliteDb(String dbFilePath) {
        this.dbUrl = "jdbc:sqlite:" + dbFilePath;
    }

    public void saveRoute(Route route) throws SQLException {
        try (var c = DriverManager.getConnection(dbUrl);
             var q = c.prepareStatement("""
                      INSERT INTO routes (
                          id,
                          name,
                          type,
                          start,
                          end,
                          distance,
                          total_time,
                          moving_time,
                          stops_count,
                          stops_duration,
                          untracked_distance,
                          min_lat,
                          max_lat,
                          min_lon,
                          max_lon
                          )
                      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                     """)) {
            q.setInt(1, route.id);
            q.setString(2, route.name);
            q.setString(3, route.type.toString());
            q.setInt(4, route.start);
            q.setInt(5, route.end);
            q.setInt(6, route.distance);
            q.setInt(7, route.total_time);
            q.setInt(8, route.moving_time);
            q.setInt(9, route.stops_count);
            q.setInt(10, route.stops_duration);
            q.setInt(11, route.untracked_distance);
            q.setFloat(12, route.min_lat);
            q.setFloat(13, route.max_lat);
            q.setFloat(14, route.min_lat);
            q.setFloat(15, route.max_lon);
            q.executeUpdate();
        }
    }

    public Route getRoute(int id) throws Exception {
        try (var c = DriverManager.getConnection(dbUrl);
             var s = c.prepareStatement("SELECT * FROM routes WHERE id = ?")) {
            s.setInt(1, id);
            var rs = s.executeQuery();
            if (!rs.next()) return null;
            return routeFromResultSet(rs);
        }
    }

    public List<Route> getRoutes() throws SQLException {
        try (var c = DriverManager.getConnection(dbUrl);
             var s = c.prepareStatement("SELECT * FROM routes")) {
            var rs = s.executeQuery();
            var list = new ArrayList<Route>();
            while (rs.next()) {
                list.add(routeFromResultSet(rs));
            }
            return list;
        }
    }

    public void saveBike(Bike bike) throws SQLException {
        try (var c = DriverManager.getConnection(dbUrl);
             var q = c.prepareStatement("""
                      INSERT INTO bikes (
                          id,
                          name,
                          distance,
                          time,
                          created_at,
                          archived
                          )
                      VALUES (?, ?, ?, ?, ?, ?)
                     """)) {
            q.setString(1, bike.id);
            q.setString(2, bike.name);
            q.setInt(3, bike.distance);
            q.setInt(4, bike.time);
            q.setLong(5, bike.created_at.getEpochSecond());
            q.setBoolean(6, bike.archived);
            q.executeUpdate();
        }
    }

    public List<Bike> getBikes() throws Exception {
        try (var c = DriverManager.getConnection(dbUrl);
             var s = c.prepareStatement("SELECT * FROM bikes ORDER BY created_at DESC")) {
            var rs = s.executeQuery();
            var list = new ArrayList<Bike>();
            while (rs.next()) {
                list.add(bikeFromResultSet(rs));
            }
            return list;
        }
    }

    Route routeFromResultSet(ResultSet rs) throws SQLException {
        var route = new Route();
        route.id = rs.getInt("id");
        route.name = rs.getString("name");
        route.type = Route.Type.valueOf(rs.getString("type"));
        route.start = rs.getInt("start");
        route.end = rs.getInt("end");
        route.distance = rs.getInt("distance");
        route.total_time = rs.getInt("total_time");
        route.moving_time = rs.getInt("moving_time");
        route.stops_count = rs.getInt("stops_count");
        route.stops_duration = rs.getInt("stops_duration");
        route.untracked_distance = rs.getInt("untracked_distance");
        route.min_lat = rs.getFloat("min_lat");
        route.max_lat = rs.getFloat("max_lat");
        route.min_lon = rs.getFloat("min_lon");
        route.max_lon = rs.getFloat("max_lon");
        return route;
    }

    Bike bikeFromResultSet(ResultSet rs) throws SQLException {
        var bike = new Bike();
        bike.id = rs.getString("id");
        bike.name = rs.getString("name");
        bike.distance = rs.getInt("distance");
        bike.time = rs.getInt("time");
        bike.created_at = Instant.ofEpochMilli(rs.getInt("created_at") * 1000L);
        bike.archived = rs.getBoolean("archived");
        return bike;
    }

}
