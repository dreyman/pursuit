package photos;

import util.Sql;

import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;

public class Repository {

    public static final String table = "photo";
    String db_url;

    public Repository(String db_file_path) {
        this.db_url = "jdbc:sqlite:" + db_file_path;
    }

    public int insert(Photo p) throws SQLException {
        var query = Sql.insertOne(table,
                "file", "timestamp", "derived_location_lat",
                "derived_location_lon", "metadata_timestamp", "metadata_timezone",
                "metadata_location_lat", "metadata_location_lon",
                "metadata_gps_timestamp", "metadata_make", "metadata_model");
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(query)) {
            var md = p.metadata != null ? p.metadata : Metadata.empty();
            var i = 0;
            s.setString(++i, p.file);
            if (p.timestamp != null)
                s.setInt(++i, p.timestamp);
            else
                s.setNull(++i, Types.INTEGER);
            if (p.derived_location != null) {
                s.setFloat(++i, p.derived_location.lat);
                s.setFloat(++i, p.derived_location.lon);
            } else {
                s.setNull(++i, Types.REAL);
                s.setNull(++i, Types.REAL);
            }
            if (md.timestamp() != null)
                s.setInt(++i, md.timestamp());
            else
                s.setNull(++i, Types.INTEGER);

            if (md.timezone() != null)
                s.setString(++i, md.timezone());
            else
                s.setNull(++i, Types.VARCHAR);

            if (md.location() != null) {
                s.setFloat(++i, md.location().lat);
                s.setFloat(++i, md.location().lon);
            } else {
                s.setNull(++i, Types.FLOAT);
                s.setNull(++i, Types.FLOAT);
            }
            if (md.gps_timestamp() != null)
                s.setInt(++i, md.gps_timestamp());
            else
                s.setNull(++i, Types.INTEGER);
            if (md.make() != null)
                s.setString(++i, md.make());
            else
                s.setNull(++i, Types.VARCHAR);

            if (md.make() != null)
                s.setString(++i, md.model());
            else
                s.setNull(++i, Types.VARCHAR);

            var count = s.executeUpdate();
            if (count != 1)
                return 0;
            var generatedKeys = s.getGeneratedKeys();
            if (generatedKeys.next()) {
                return generatedKeys.getInt(1);
            }
            return 0;
        }
    }

    public List<Photo> listAll() throws SQLException {
        var sql = "SELECT * FROM " + table;
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            var rs = s.executeQuery();
            return Photo.listFromResultSet(rs);
        }
    }

    public List<Photo> list() throws SQLException {
        var sql = "SELECT * FROM " + table +
                " WHERE timestamp > 0 AND derived_location_lat IS NOT NULL LIMIT 15";
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            var rs = s.executeQuery();
            return Photo.listFromResultSet(rs);
        }
    }

    public List<Photo> listWithoutMetadataTimezone() throws SQLException {
        var sql = "SELECT * FROM " + table + " WHERE " +
                "metadata_timezone IS NULL AND " +
                "metadata_timestamp IS NOT NULL";
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            var rs = s.executeQuery();
            return Photo.listFromResultSet(rs);
        }
    }

    public void updateTimestamp(int id, int timestamp) throws SQLException {
        var sql = "UPDATE " + table + " SET timestamp = " + timestamp + " WHERE id = " + id;
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            int i = s.executeUpdate();
            if (i != 1)
                throw new RuntimeException("UNEXPECTED result: " + i);
        }
    }

    public int updateDerivedLocation(Photo p) throws SQLException {
        if (p == null || p.id <= 0 || p.derived_location == null)
            throw new InternalError();
        var sql = "UPDATE " + table + " SET " +
                "derived_location_lat = ?, " +
                "derived_location_lon = ? " +
                "WHERE id = ?";
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            int i = 0;
            s.setFloat(++i, p.derived_location.lat);
            s.setFloat(++i, p.derived_location.lon);
            s.setInt(++i, p.id);
            return s.executeUpdate();
        }
    }

    public Photo getById(int id) throws SQLException {
        var sql = "SELECT * FROM " + table + " WHERE id = ?";
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            s.setInt(1, id);
            var rs = s.executeQuery();
            if (!rs.next())
                return null;
            return Photo.fromResultSet(rs);
        }
    }

    public void setup() throws SQLException {
        var sql = "CREATE TABLE " + table + "(" +
                "id INTEGER PRIMARY KEY," +
                "file TEXT NOT NULL UNIQUE," +
                "timestamp INTEGER," +
                "derived_location_lat REAL," +
                "derived_location_lon REAL," +
                "metadata_timestamp INTEGER," +
                "metadata_timezone TEXT," +
                "metadata_location_lat REAL," +
                "metadata_location_lon REAL," +
                "metadata_gps_timestamp INTEGER," +
                "metadata_make TEXT," +
                "metadata_model TEXT" +
                ") strict";
        try (var c = DriverManager.getConnection(db_url);
             var s = c.prepareStatement(sql)) {
            s.execute();
        }
    }
}
