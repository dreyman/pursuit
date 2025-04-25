import landmarks.Landmark;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class Migration {
//    public static String from_db = "/home/ihor/code/mapit/dev/dev.db";
//    public static String to_db = "/home/ihor/code/pursuit/server/dev/storage/pursuit.db";
//
//    public static void migrate(landmarks.Api api) throws SQLException {
//        var select_all = "SELECT * FROM points";
//        var lms = List.<landmarks.Payload>of();
//        try (var c = DriverManager.getConnection(dbUrlFromFile(from_db));
//             var s = c.prepareStatement(select_all)) {
//            var rs = s.executeQuery();
//            lms = lmsFromResult(rs);
//        }
//
//        for (landmarks.Payload lm : lms) {
////            Landmark landmark = new Landmark();
////            landmark.name = lm.name;
////            landmark.lat = lm.lat;
////            landmark.lon = lm.lon;
//            api.create(lm);
//        }
//    }
//
//    static String dbUrlFromFile(String db_file_path) {
//        return "jdbc:sqlite:" + db_file_path;
//    }
//
//    static List<landmarks.Payload> lmsFromResult(ResultSet rs) throws SQLException {
//        var list = new ArrayList<landmarks.Payload>();
//        while (rs.next()) list.add(fromResultSet(rs));
//        return list;
//    }
//
//    static landmarks.Payload fromResultSet(ResultSet rs) throws SQLException {
//        var lm = new landmarks.Payload();
//        lm.name = rs.getString("name");
//        lm.lat = rs.getFloat("lat");
//        lm.lon = rs.getFloat("lon");
//        return lm;
//    }
}
