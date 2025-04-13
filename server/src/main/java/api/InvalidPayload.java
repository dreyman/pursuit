package api;

import java.util.Map;

public class InvalidPayload extends RuntimeException {
    public Map<String, String> invalid_fields;

    public InvalidPayload(Map<String, String> invalid_fields) {
        this.invalid_fields = invalid_fields;
    }
}
