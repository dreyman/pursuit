package api;

public class InternalError extends RuntimeException {

public InternalError() {}

public InternalError(String message) {
    super(message);
}
}
