package landmarks;

import db.StrictSqlite;

import java.util.List;

public class Service {

Repository repo;
StrictSqlite db;

public Service(String sqlite_db_file) {
    db = new db.jdbc.Sqlite(sqlite_db_file);
    repo = new landmarks.Repository(db);
}

public void setup() {
    repo.setup();
}

public List<Landmark> query() {
    return repo.list();
}

public Landmark getById(int id) {
    return repo.getById(id);
}

public int create(Payload payload) {
    var lm = new Landmark();
    lm.created_at = (int) (System.currentTimeMillis() / 1000);
    payload.setFields(lm);
    return repo.insert(lm);
}

public boolean delete(int id) {
    return repo.delete(id);
}

}
