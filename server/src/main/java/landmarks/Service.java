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

    public Landmark getById(int id) {
        try {
            return repo.getById(id);
        } catch (SQLException x) {
            throw new RuntimeException(x);
        }
    }

    public int create(Payload payload) {
        var lm = new Landmark();
        lm.created_at = (int) (System.currentTimeMillis() / 1000);
        payload.setFields(lm);
        try {
            int id = repo.insert(lm);
            if (id == 0)
                throw new api.InternalError();
            return id;
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }

    public boolean delete(int id) {
        try {
            return repo.delete(id);
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }
}
