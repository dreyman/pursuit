package pursuit.sqlite;

import pursuit.UpdatePayload;

import java.sql.PreparedStatement;
import java.sql.SQLException;

public class UpdateQuery {
    int id;
    UpdatePayload payload;

    public UpdateQuery(int id, UpdatePayload payload) {
        this.id = id;
        this.payload = payload;
    }

    public String buildSql(String table) {
        var sql = new StringBuilder("UPDATE ").append(table);

        var set = new StringBuilder();
        if (payload.name != null) {
            set.append("name = ?");
        }
        if (payload.description != null) {
            if (!set.isEmpty()) set.append(", ");
            set.append("description = ?");
        }
        if (payload.kind != null) {
            if (!set.isEmpty()) set.append(", ");
            set.append("kind = ?");
        }
        if (payload.medium_id != null) {
            if (!set.isEmpty()) set.append(", ");
            set.append("medium_id = ?");
        }

        if (set.isEmpty()) return null;
        sql.append(" SET ").append(set).append(" WHERE id = ?");

        return sql.toString();
    }

    public void setArgs(PreparedStatement s) throws SQLException {
        var i = 0;
        if (payload.name != null) s.setString(++i, payload.name);
        if (payload.description != null) s.setString(++i, payload.description);
        if (payload.kind != null) s.setInt(++i, payload.kind.ordinal());
        if (payload.medium_id != null) {
            if (payload.medium_id == 0) s.setNull(++i, java.sql.Types.INTEGER);
            else s.setInt(++i, payload.medium_id);
        }
        s.setInt(++i, id);
    }
}
