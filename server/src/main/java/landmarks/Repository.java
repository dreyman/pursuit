package landmarks;

import db.StrictSqlite;
import util.Sql;

import java.util.List;

public class Repository {

public static final String table = "landmark";
StrictSqlite db;

public Repository(StrictSqlite database) {
    this.db = database;
}

public List<Landmark> list() {
    try (var tx = db.transaction()) {
        var res = tx.query("SELECT * FROM " + table);
        return Landmark.createList(res);
    }
}

public Landmark getById(int id) {
    try (var tx = db.transaction()) {
        var res = tx.query("SELECT * " + "FROM " + table + " WHERE id = ?", id);
        if (!res.next())
            return null;
        return Landmark.create(res);
    }
}

public int insert(Landmark lm) {
    try (var tx = db.transaction()) {
        var res = tx.query(
                Sql.insertOne(table, "name", "lat", "lon", "created_at"),
                lm.name, lm.lat, lm.lon, lm.created_at);
        assert res.next();
        int id = res.getInt("id");
        tx.commit();
        return id;
    }
}

public boolean delete(int id) {
    try (var tx = db.transaction()) {
        int count = tx.update("DELETE FROM " + table + " WHERE id = ?", id);
        assert count == 0 || count == 1;
        tx.commit();
        return count == 1;
    }
}

public void setup() {
    var sql = "CREATE TABLE " + table + "(" +
            "id INTEGER PRIMARY KEY," +
            "name TEXT NOT NULL," +
            "lat REAL NOT NULL," +
            "lon REAL NOT NULL," +
            "created_at INTEGER NOT NULL" +
            ") strict";
    db.execute(sql);
}

}
