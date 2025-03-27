package api;

import java.sql.PreparedStatement;
import java.sql.SQLException;

public interface ApiRequest {

    String buildQuery(String prefix);

    void setArgs(PreparedStatement stmt) throws SQLException;
}
