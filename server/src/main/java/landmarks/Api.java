package landmarks;

import java.sql.SQLException;
import java.util.List;

public class Api {
    Repository repo;

    public Api(String sqlite_db_file) {
        repo = new landmarks.Repository(sqlite_db_file);
    }

    public void setup() {
        try {
            repo.setup();
        } catch (SQLException x) {
            x.printStackTrace();
            throw new RuntimeException(x);
        }
    }

    public List<Landmark> query() {
        try {
            return repo.list();
        } catch (SQLException x) {
            x.printStackTrace();
            return List.of();
        }
    }

    public void create(Landmark lm) {
        lm.created_at = (int) (System.currentTimeMillis() / 1000);
        try {
            repo.insert(lm);
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }
}
