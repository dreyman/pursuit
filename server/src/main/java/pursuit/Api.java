package pursuit;

import java.sql.SQLException;
import java.util.List;

public class Api {
    Repository repo;

    public Api(Repository repository) {
        this.repo = repository;
    }

    public List<ListItem> list(ListParams params) {
        try {
            return repo.list(params);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
