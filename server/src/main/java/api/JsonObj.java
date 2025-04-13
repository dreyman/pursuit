package api;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

public class JsonObj {
    String json;
    JsonObject jo;

    static Gson gson = new Gson();

    public JsonObj(String json) {
        this.json = json;
        this.jo = gson.fromJson(json, JsonObject.class);
    }

    public record Result<T>(T val, String err) {}

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
            return new Result<>(0, intFieldDescription(min, max));
        }
    }

    static String intFieldDescription(int min, int max) {
        return String.format("Must be an integer in the range [%d, %d]", min, max);
    }


}
