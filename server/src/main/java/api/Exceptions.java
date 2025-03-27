package api;

public class Exceptions {
    public static InvalidRequest invalidUintParam(String param) {
        return new InvalidRequest("Invalid '" + param + "' param value. Must be an integer > 0.");
    }
}
