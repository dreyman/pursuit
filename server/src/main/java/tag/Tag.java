package tag;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class Tag {

public int id;
public String name;

public static Tag fromResultSet(ResultSet rs) throws SQLException {
    var tag = new Tag();
    tag.id = rs.getInt("id");
    tag.name = rs.getString("name");
    return tag;
}

public static List<Tag> listFromResultSet(ResultSet rs) throws SQLException {
    var list = new ArrayList<Tag>();
    while (rs.next()) list.add(fromResultSet(rs));
    return list;
}

}
