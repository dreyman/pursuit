package api;

import java.sql.PreparedStatement;
import java.sql.SQLException;

public interface ApiRequest {

    String buildQuery(String select_query);

    void setArgs(PreparedStatement stmt) throws SQLException;
}
