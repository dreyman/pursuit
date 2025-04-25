package stats;

import api.JsonPayload;
import com.google.gson.JsonSyntaxException;

public class RecalcRequest {
    public int min_speed;
    public int max_time_gap;

    private RecalcRequest() {}

    public static RecalcRequest fromJson(String json) {
        var errors = new java.util.HashMap<String, String>(2);
        JsonPayload payload;
        try {
            payload = new JsonPayload(json);
        } catch (JsonSyntaxException x) {
            payload = new JsonPayload("{}");
        }
        RecalcRequest result = new RecalcRequest();
        var val = payload.getInt("min_speed", 0, 255);
        if (val.err() != null) errors.put("min_speed", val.err());
        else result.min_speed = val.val();

        val = payload.getInt("max_time_gap", 0, 255);
        if (val.err() != null) errors.put("max_time_gap", val.err());
        else result.max_time_gap = val.val();

        if (!errors.isEmpty())
            throw new api.InvalidPayload(errors);

        return result;
    }
}
