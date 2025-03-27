package pursuit;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class UpdatePayloadTest {

    @Test
    void buildQuery() {
        var payload = new UpdatePayload();
        payload.id = 42;
        payload.name = "New name";

        var q = payload.buildQuery("UPDATE tbl");

        assertTrue(payload.isValid());
        assertEquals("UPDATE tbl SET name = ? WHERE id = ?", q);
    }
}
