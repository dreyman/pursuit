package app;

import app.model.Route;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SqliteDb implements Database {

    private final String dbUrl;

    public SqliteDb(String dbFilePath) {
        this.dbUrl = "jdbc:sqlite:" + dbFilePath;
    }

    public void saveRoute(Route route) throws Exception {
        try (var c = DriverManager.getConnection(dbUrl);
             var insertRoute = c.prepareStatement("INSERT INTO routes (id, name) VALUES (?, ?)");
             var insertStats = c.prepareStatement("""
                     INSERT INTO route_stats (
                                         route_type,
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
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                     """)) {
            insertStats.setString(1, route.stats.routeType().toString());
            insertStats.setInt(2, route.stats.start());
            insertStats.setInt(3, route.stats.end());
            insertStats.setInt(4, route.stats.distance());
            insertStats.setInt(5, route.stats.totalTime());
            insertStats.setInt(6, route.stats.movingTime());
            insertStats.setInt(7, route.stats.stopsCount());
            insertStats.setInt(8, route.stats.stopsDuration());
            insertStats.setInt(9, route.stats.untrackedDistance());
            insertStats.setFloat(10, route.stats.minLat());
            insertStats.setFloat(11, route.stats.maxLat());
            insertStats.setFloat(12, route.stats.minLat());
            insertStats.setFloat(13, route.stats.maxLon());

            insertRoute.setInt(1, route.id);
            insertRoute.setString(2, route.name);

            insertStats.executeUpdate();
            insertRoute.executeUpdate();
        }
    }

    public Route getRoute(int id) throws Exception {
        try (var c = DriverManager.getConnection(dbUrl);
             var s = c.prepareStatement("SELECT r.*, s.* FROM routes as r JOIN route_stats as s ON r.id = s.start WHERE id = ?")) {
            s.setInt(1, id);
            var rs = s.executeQuery();
            if (!rs.next()) return null;
            return routeFromResultSet(rs);
        }
    }

    public List<Route> getRoutes() throws SQLException {
        try (var c = DriverManager.getConnection(dbUrl);
             var s = c.prepareStatement("SELECT r.*, s.* FROM routes r JOIN route_stats s ON r.id = s.start")) {
            var rs = s.executeQuery();
            var list = new ArrayList<Route>();
            while (rs.next()) {
                list.add(routeFromResultSet(rs));
            }
            return list;
        }
    }

    Route routeFromResultSet(ResultSet rs) throws SQLException {
        var route = new Route();
        route.id = rs.getInt("id");
        route.name = rs.getString("name");
        route.stats = new Route.Stats(
                Route.Type.valueOf(rs.getString("route_type")),
                rs.getInt("start"),
                rs.getInt("end"),
                rs.getInt("distance"),
                rs.getInt("total_time"),
                rs.getInt("moving_time"),
                rs.getInt("stops_count"),
                rs.getInt("stops_duration"),
                rs.getInt("untracked_distance"),
                rs.getFloat("min_lat"),
                rs.getFloat("max_lat"),
                rs.getFloat("min_lon"),
                rs.getFloat("max_lon")
        );
        return route;
    }

    // TODO
    public void init() throws SQLException {
        var conn = DriverManager.getConnection(dbUrl);
        var stmt = conn.createStatement();
        stmt.executeQuery(create_route_stats_table_sql);
        stmt.executeQuery(create_routes_table_sql);
    }

    static String create_route_stats_table_sql = """
                CREATE TABLE IF NOT EXISTS route_stats (
                    route_type TEXT NOT NULL,
                    start INTEGER NOT NULL,
                    end INTEGER NOT NULL,
                    distance INTEGER NOT NULL,
                    total_time INTEGER NOT NULL,
                    moving_time INTEGER NOT NULL,
                    stops_count INTEGER NOT NULL,
                    stops_duration INTEGER NOT NULL,
                    untracked_distance INTEGER NOT NULL,
                    min_lat REAL NOT NULL,
                    max_lat REAL NOT NULL,
                    min_lon REAL NOT NULL,
                    max_lon REAL NOT NULL
                );
            """;

    static String create_routes_table_sql = """
                CREATE TABLE IF NOT EXISTS routes (
                    id INTEGER PRIMARY KEY,
                    name TEXT NOT NULL
                );
            """;

}
