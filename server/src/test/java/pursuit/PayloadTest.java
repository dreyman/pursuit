package pursuit;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class PayloadTest {

    @Test
    void buildQuery() {
        var payload = new UpdatePayload();
        String table = "some_table";

        payload.name = "New name";

        var sql = payload.buildSql(table);
        assertEquals("UPDATE some_table SET name = ? WHERE id = ?", sql);
    }
}
