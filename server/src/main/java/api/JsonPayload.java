package api;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.List;

public class JsonPayload {
String json;
JsonObject jo;

static Gson gson = new Gson();

public JsonPayload(String json) {
    this.json = json;
    this.jo = gson.fromJson(json, JsonObject.class);
}

public record Result<T>(T val, String err) {}

public Result<String> getString(String name, int len_min, int len_max) {
    try {
        String str = jo.get(name).getAsString();
        if (str.length() < len_min || str.length() > len_max)
            return new Result<>(null, stringFieldDescription(len_min, len_max));
        return new Result<>(str, null);
    } catch (NullPointerException _) {
        return new Result<>(null, "Required. " + stringFieldDescription(len_min, len_max));
    } catch (UnsupportedOperationException |
             IllegalStateException |
             NumberFormatException _) {
        return new Result<>(null, "Invalid. " + stringFieldDescription(len_min, len_max));
    }
}

public Result<Integer> getInt(String name,
                              int min,
                              int max) {
    try {
        int val = jo.get(name).getAsInt();
        if (val < min || val > max)
            return new Result<>(0, intFieldDescription(min, max));
        return new Result<>(val, null);
    } catch (NullPointerException _) {
        return new Result<>(0, "Required. " + intFieldDescription(min, max));
    } catch (UnsupportedOperationException |
             IllegalStateException |
             NumberFormatException _) {
        return new Result<>(0, "Invalid. " + intFieldDescription(min, max));
    }
}

public Result<Float> getFloat(String name,
                              float min,
                              float max) {
    try {
        float val = jo.get(name).getAsFloat();
        if (val < min || val > max)
            return new Result<>(0f, numberFieldDescription(min, max));
        return new Result<>(val, null);
    } catch (NullPointerException _) {
        return new Result<>(0f, "Required. " + numberFieldDescription(min, max));
    } catch (UnsupportedOperationException |
             IllegalStateException |
             NumberFormatException _) {
        return new Result<>(0f, "Invalid. " + numberFieldDescription(min, max));
    }
}

static String intFieldDescription(int min, int max) {
    return String.format("Must be an integer in the range [%d, %d]", min, max);
}

static String stringFieldDescription(int len_min, int len_max) {
    return String.format("Must be a string with length in the range [%d, %d]", len_min, len_max);
}

static String numberFieldDescription(float min, float max) {
    return String.format("Must be a number in the range [%.0f, %.0f]", min, max);
}

}
