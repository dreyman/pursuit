package api;

public class InvalidRequest extends RuntimeException {
    public InvalidRequest(String msg) {
        super(msg);
    }
}
