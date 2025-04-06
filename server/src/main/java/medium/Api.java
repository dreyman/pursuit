package medium;

import java.sql.SQLException;
import java.util.List;

public class Api {
    Repository repo;

    public Api(String sqlite_db_file) {
        repo = new Repository(sqlite_db_file);
    }

    public List<Medium> query() {
        try {
            return repo.list();
        } catch (SQLException x) {
            return List.of();
        }
    }
}
