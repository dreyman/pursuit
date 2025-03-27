package medium;

import java.sql.SQLException;
import java.util.List;

public class Api {
    Repository repo;

    public Api(Repository repository) {
        this.repo = repository;
    }

    public List<Medium> list(ListParams req) {
        try {
            return repo.list(req);
        } catch (SQLException x) {
            throw new RuntimeException(x);
        }
    }
}
