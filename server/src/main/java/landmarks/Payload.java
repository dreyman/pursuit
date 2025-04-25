package landmarks;

import api.JsonPayload;
import com.google.gson.JsonSyntaxException;

import static core.Constants.*;

public class Payload {
    static int name_len_min = 1;
    static int name_len_max = 100;

    String name;
    float lat;
    float lon;

    public static Payload fromJson(String json_str) {
        var errors = new java.util.HashMap<String, String>(2);
        JsonPayload json;
        try {
            json = new JsonPayload(json_str);
        } catch (JsonSyntaxException x) {
            json = new JsonPayload("{}");
        }
        Payload result = new Payload();
        var val = json.getFloat("lat", latitude_min, latitude_max);
        if (val.err() != null) errors.put("lat", val.err());
        else result.lat = val.val();

        val = json.getFloat("lon", longitude_min, longitude_max);
        if (val.err() != null) errors.put("lon", val.err());
        else result.lon = val.val();

        var name = json.getString("name", name_len_min, name_len_max);
        if (name.err() != null) errors.put("name", name.err());
        else result.name = name.val();

        if (!errors.isEmpty())
            throw new api.InvalidPayload(errors);

        return result;
    }

    public void setFields(Landmark lm) {
        lm.name = this.name;
        lm.lat = this.lat;
        lm.lon = this.lon;
    }
}
