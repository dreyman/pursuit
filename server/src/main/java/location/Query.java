package location;

import api.JsonPayload;
import com.google.gson.JsonSyntaxException;

import java.util.List;

import static core.Constants.*;

public class Query {
    static final int default_time_gap = 60;
    static final double default_max_distance = 0.1;

    public float lat;
    public float lon;
    public int time_gap;
    public double max_distance;

    public static Query fromJson(String json_str) {
        var errors = new java.util.HashMap<String, String>(2);
        JsonPayload json;
        try {
            json = new JsonPayload(json_str);
        } catch (JsonSyntaxException x) {
            json = new JsonPayload("{}");
        }
        var result = new Query();
        var val = json.getFloat("lat", latitude_min, latitude_max);
        if (val.err() != null) errors.put("lat", val.err());
        else result.lat = val.val();

        val = json.getFloat("lon", longitude_min, longitude_max);
        if (val.err() != null) errors.put("lon", val.err());
        else result.lon = val.val();

        result.time_gap = default_time_gap;
        result.max_distance = default_max_distance;

        if (!errors.isEmpty())
            throw new api.InvalidPayload(errors);

        return result;
    }

    static String firstOrNull(List<String> values) {
        if (values == null || values.isEmpty())
            return null;
        return values.get(0);
    }
}
