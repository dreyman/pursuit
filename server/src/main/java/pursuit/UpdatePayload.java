package pursuit;

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;

public class UpdatePayload {

public String name;
public String description;
public Pursuit.Kind kind;
public Integer medium_id;

public boolean isEmpty() {
    return name == null &&
            description == null &&
            kind == null &&
            medium_id == null;
}

public String buildSql(String table) {
    var set = new StringBuilder();
    if (this.name != null) {
        set.append("name = ?");
    }
    if (this.description != null) {
        if (!set.isEmpty()) set.append(", ");
        set.append("description = ?");
    }
    if (this.kind != null) {
        if (!set.isEmpty()) set.append(", ");
        set.append("kind = ?");
    }
    if (this.medium_id != null) {
        if (!set.isEmpty()) set.append(", ");
        set.append("medium_id = ?");
    }
    if (set.isEmpty())
        return null;

    return "UPDATE " + table +
            " SET " + set +
            " WHERE id = ?";
}

public void setArgs(int id, PreparedStatement s) throws SQLException {
    var i = 0;
    if (this.name != null) s.setString(++i, this.name);
    if (this.description != null) s.setString(++i, this.description);
    if (this.kind != null) s.setInt(++i, this.kind.ordinal());
    if (this.medium_id != null) {
        if (this.medium_id == 0)
            s.setNull(++i, Types.REAL);
        else s.setInt(++i, this.medium_id);
    }
    s.setInt(++i, id);
}

}
