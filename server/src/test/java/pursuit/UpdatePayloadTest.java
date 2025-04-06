package pursuit;

import org.junit.jupiter.api.Test;
import pursuit.sqlite.UpdateQuery;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class UpdatePayloadTest {

    @Test
    void buildQuery() {
        var payload = new UpdatePayload();
        int id = 42;
        String table = "some_table";

        payload.name = "New name";
        var q = new UpdateQuery(id, payload);

        var sql = q.buildSql(table);
        assertEquals("UPDATE some_table SET name = ? WHERE id = ?", sql);
    }
}
