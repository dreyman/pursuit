package photos;

import core.Location;

import java.sql.ResultSet;
import java.sql.SQLException;

public record Metadata(Integer timestamp,
                       String timezone,
                       Location location,
                       Integer gps_timestamp,
                       String make,
                       String model) {

public String device() {
    var sb = new StringBuilder();
    if (make != null) sb.append(make);
    if (model != null) {
        if (sb.isEmpty()) sb.append(model);
        else sb.append(" ").append(model);
    }
    return sb.isEmpty() ? "Unknown" : sb.toString();

}

public static Metadata empty() {
    return new Metadata(null, null, null, null, null, null);
}

static Metadata fromResultSet(ResultSet rs, String prefix) throws SQLException {
    Integer timestamp = rs.getInt(prefix + "timestamp");
    if (rs.wasNull())
        timestamp = null;

    var timezone = rs.getString(prefix + "timezone");
    if (rs.wasNull())
        timezone = null;

    Location location = null;
    var lat = rs.getFloat(prefix + "location_lat");
    if (!rs.wasNull())
        location = new Location(lat, rs.getFloat(prefix + "location_lon"));

    Integer gps_timestamp = rs.getInt(prefix + "gps_timestamp");
    if (rs.wasNull())
        gps_timestamp = null;

    var make = rs.getString(prefix + "make");
    if (rs.wasNull())
        make = null;

    var model = rs.getString(prefix + "model");
    if (rs.wasNull())
        model = null;

    return new Metadata(timestamp, timezone, location, gps_timestamp, make, model);
}

@Override
public String toString() {
    return "Metadata{" +
            "timestamp=" + timestamp +
            ", timezone='" + timezone + '\'' +
            ", location=" + location +
            ", gps_timestamp=" + gps_timestamp +
            ", make='" + make + '\'' +
            ", model='" + model + '\'' +
            '}';
}
}
