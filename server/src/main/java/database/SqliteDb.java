package database;

import pursuit.Pursuit;

import java.sql.DriverManager;
import java.util.ArrayList;
import java.util.List;

public class SqliteDb {

    private final String dbUrl;

    public SqliteDb(String dbFilePath) {
        this.dbUrl = "jdbc:sqlite:" + dbFilePath;
    }

//    public void saveRoute(Route route) throws SQLException {
//        try (var c = DriverManager.getConnection(dbUrl);
//             var q = c.prepareStatement("""
//                      INSERT INTO routes (
//                          id,
//                          name,
//                          type,
//                          start,
//                          end,
//                          distance,
//                          total_time,
//                          moving_time,
//                          stops_count,
//                          stops_duration,
//                          untracked_distance,
//                          min_lat,
//                          max_lat,
//                          min_lon,
//                          max_lon
//                          )
//                      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
//                     """)) {
//            q.setInt(1, route.id);
//            q.setString(2, route.name);
//            q.setString(3, route.type.toString());
//            q.setInt(4, route.start);
//            q.setInt(5, route.end);
//            q.setInt(6, route.distance);
//            q.setInt(7, route.total_time);
//            q.setInt(8, route.moving_time);
//            q.setInt(9, route.stops_count);
//            q.setInt(10, route.stops_duration);
//            q.setInt(11, route.untracked_distance);
//            q.setFloat(12, route.min_lat);
//            q.setFloat(13, route.max_lat);
//            q.setFloat(14, route.min_lat);
//            q.setFloat(15, route.max_lon);
//            q.executeUpdate();
//        }
//    }

    public Pursuit getPursuit(int id) throws Exception {
        try (var c = DriverManager.getConnection(dbUrl);
             var s = c.prepareStatement("SELECT * FROM pursuit WHERE id = ?")) {
            s.setInt(1, id);
            var rs = s.executeQuery();
            if (!rs.next()) return null;
            return Pursuit.fromResultSet(rs);
        }
    }

//    public void saveBike(Bike bike) throws SQLException {
//        try (var c = DriverManager.getConnection(dbUrl);
//             var q = c.prepareStatement("""
//                      INSERT INTO bike (
//                          name,
//                          distance,
//                          time,
//                          created_at,
//                          archived
//                          )
//                      VALUES ?, ?, ?, ?, ?)
//                     """)) {
//            var i = 0;
//            q.setString(++i, bike.id);
//            q.setString(++i, bike.name);
//            q.setInt(++i, bike.distance);
//            q.setInt(++i, bike.time);
//            q.setLong(++i, bike.created_at.getEpochSecond());
//            q.setBoolean(++i, bike.archived);
//            q.executeUpdate();
//        }
//    }

    public List<Pursuit> getPursuits() throws Exception {
        try (var c = DriverManager.getConnection(dbUrl);
             var s = c.prepareStatement("SELECT * FROM pursuit ORDER BY id DESC LIMIT 25")) {
            var rs = s.executeQuery();
            var list = new ArrayList<Pursuit>();
            while (rs.next()) {
                list.add(Pursuit.fromResultSet(rs));
            }
            return list;
        }
    }

//    public List<Bike> getBikes() throws Exception {
//        try (var c = DriverManager.getConnection(dbUrl);
//             var s = c.prepareStatement("SELECT * FROM bike ORDER BY created_at DESC")) {
//            var rs = s.executeQuery();
//            var list = new ArrayList<Bike>();
//            while (rs.next()) {
//                list.add(Bike.fromResultSet(rs));
//            }
//            return list;
//        }
//    }

}
