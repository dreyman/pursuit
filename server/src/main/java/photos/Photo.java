package photos;

import core.Location;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class Photo {

    public int id;
    public String file;
    public Integer timestamp;
    public Location derived_location;
    public Metadata metadata;
    // TODO manual_location - for manually set location

    public static Photo fromResultSet(ResultSet rs) throws SQLException {
        var p = new Photo();
        p.id = rs.getInt("id");
        p.file = rs.getString("file");
        p.timestamp = rs.getInt("timestamp");
        if (rs.wasNull())
            p.timestamp = null;

        p.derived_location = null;
        var derived_lat = rs.getFloat("derived_location_lat");
        if (!rs.wasNull())
            p.derived_location = new Location(derived_lat, rs.getFloat("derived_location_lon"));

        p.metadata = Metadata.fromResultSet(rs, "metadata_");
//        p.metadata.timestamp = rs.getInt("metadata_timestamp");
//        if (rs.wasNull())
//            p.metadata.timestamp = null;
//
//        p.metadata.timezone = rs.getString("metadata_timezone");
//        if (rs.wasNull())
//            p.metadata.timezone = null;
//
//        p.metadata.location = null;
//        var lat = rs.getFloat("metadata_location_lat");
//        if (!rs.wasNull())
//            p.metadata.location = new Location(lat, rs.getFloat("metadata_location_lon"));
//
//        p.metadata.gps_timestamp = rs.getInt("metadata_gps_timestamp");
//        if (rs.wasNull())
//            p.metadata.gps_timestamp = null;
//
//        p.metadata.make = rs.getString("metadata_make");
//        if (rs.wasNull())
//            p.metadata.make = null;
//
//        p.metadata.model = rs.getString("metadata_model");
//        if (rs.wasNull())
//            p.metadata.model = null;

        return p;
    }

    public static List<Photo> listFromResultSet(ResultSet rs)
            throws SQLException {
        var list = new ArrayList<Photo>();
        while (rs.next()) list.add(fromResultSet(rs));
        return list;
    }
}
