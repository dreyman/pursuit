package pursuit;

import java.sql.SQLException;
import java.util.List;

public class Api {
    Repository repo;

    public Api(String sqlite_db_file) {
        repo = new Repository(sqlite_db_file);
    }

    public List<Summary> query(Query query) {
        try {
            return repo.list(query);
        } catch (SQLException x) {
            x.printStackTrace();
            return List.of();
        }
    }

    public Pursuit getById(int id) {
        try {
            return repo.getById(id);
        } catch (SQLException x) {
            throw new RuntimeException(x);
        }
    }

    public boolean update(int id, UpdatePayload payload) {
        try {
            if (payload.isEmpty())
                return true;
            var updated_count = repo.update(id, payload);
            if (updated_count > 1)
                throw new api.InternalError();
            return updated_count > 0;
        } catch (SQLException x) {
            x.printStackTrace();
            return false;
        }
    }
}
