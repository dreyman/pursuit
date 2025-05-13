package photos;

import java.sql.SQLException;
import java.time.ZoneId;
import java.util.List;

public class Api {
    public Repository repo;

    public Api(String sqlite_db_file) {
        repo = new photos.Repository(sqlite_db_file);
    }

    public void importFromDirectory(String dir) {
        var init = new Init(repo);
        try {
            init.fromDirectory(dir);
        } catch (Init.Err e) {
            throw new RuntimeException(e);
        }
    }

    public List<Photo> query() {
        try {
            return repo.list();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public Photo getById(int id) {
        try {
            return repo.getById(id);
        } catch (SQLException x) {
            throw new RuntimeException(x);
        }
    }

    public void setup() {
        try {
            repo.setup();
        } catch (SQLException x) {
            x.printStackTrace();
            throw new RuntimeException(x);
        }
    }

    public void adjustTimezone(ZoneId tz) {

    }
}
