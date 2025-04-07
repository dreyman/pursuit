package api;

public class InvalidRequest extends RuntimeException {
    public InvalidRequest(String msg) {
        super(msg);
    }

    public static InvalidRequest invalidUintParam(String name) {
        return new InvalidRequest(
                String.format("Invalid '%s' param value. Must be an integer number > 0.", name)
        );
    }
}
