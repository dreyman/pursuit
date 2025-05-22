package landmarks;

import api.InvalidPayload;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class RestApiTest {

    @Test
    public void invalidPayload() {
        var json = """
                {
                    "lat": 1000,
                    "lon": -500,
                    "name": ""
                }
                """;
        var rest = new landmarks.Rest(new Service(""));
        InvalidPayload exception = null;
        try {
            rest.create(json);
        } catch (InvalidPayload x) {
            exception = x;
        }
        assertNotNull(exception);
        assertEquals("Must be a string with length in the range [1, 100]",
                exception.invalid_fields.get("name"));
        assertEquals("Must be a number in the range [-90, 90]",
                exception.invalid_fields.get("lat"));
        assertEquals("Must be a number in the range [-180, 180]",
                exception.invalid_fields.get("lon"));
    }
}
