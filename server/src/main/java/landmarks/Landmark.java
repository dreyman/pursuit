package landmarks;

import db.StrictSqlite;

import java.util.ArrayList;
import java.util.List;

public class Landmark {

public int id;
public String name;
public float lat;
public float lon;
public int created_at;

public static Landmark create(StrictSqlite.QueryResult res) {
    var lm = new Landmark();
    lm.id = res.getInt("id");
    lm.name = res.getString("name");
    lm.lat = res.getFloat("lat");
    lm.lon = res.getFloat("lon");
    lm.created_at = res.getInt("created_at");
    return lm;
}

public static List<Landmark> createList(StrictSqlite.QueryResult res) {
    var list = new ArrayList<Landmark>();
    while (res.next()) {
        list.add(Landmark.create(res));
    }
    return list;
}

}
