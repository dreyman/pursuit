package pursuit;

import api.ApiRequestPayload;

import java.sql.PreparedStatement;
import java.sql.SQLException;

public class UpdatePayload implements ApiRequestPayload {
    public Integer id;
    public String name;
    public String description;

    public UpdatePayload() {}

    @Override
    public String buildQuery(String update_table) {
        var q = new StringBuilder(update_table);

        var set = new StringBuilder();
        if (name != null)
            set.append("name = ?");
        if (description != null) {
            if (!set.isEmpty()) set.append(", ");
            set.append("description = ?");
        }
        if (set.isEmpty()) return null; // nothing to set

        q.append(" SET ").append(set).append(" WHERE id = ?");

        return q.toString();
    }

    @Override
    public void setArgs(PreparedStatement s) throws SQLException {
        var i = 0;
        if (name != null) s.setString(++i, name);
        if (description != null) s.setString(++i, description);
        s.setInt(++i, id);
    }

    @Override
    public boolean isValid() {
        if (id == null) return false;
        // fixme proper validation
        if (allNulls(name, description))
            return false;
        var valid_name = name == null || (!name.isEmpty() && name.length() < 250);
        var valid_description = description == null || (description.length() < 2500);
        return valid_name && valid_description;
    }

    boolean allNulls(Object... args) {
        for (Object arg : args) {
            if (arg != null) return false;
        }
        return true;
    }

}
