package medium;

import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class ListParamsTest {

    @Test
    void listQuery() {
        var listRequest = new ListParams(Map.of("kind", List.of("some")));
        var query = listRequest.buildQuery("SELECT * FROM tbl");
        var expected = "SELECT * FROM tbl WHERE kind = ? and archived = ? " +
                "LIMIT " + ListParams.default_limit;
        assertEquals(expected, query);

        listRequest = new ListParams(Map.of());
        query = listRequest.buildQuery("SELECT * FROM tbl");
        expected = "SELECT * FROM tbl WHERE archived = ? " +
                "LIMIT " + ListParams.default_limit;
        assertEquals(expected, query);
    }
}
