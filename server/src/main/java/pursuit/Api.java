package pursuit;

import java.sql.SQLException;
import java.util.List;

public class Api {
    public class InvalidPayload extends RuntimeException {
        public InvalidPayload(String msg) {
            super(msg);
        }
    }

    Repository repo;

    public Api(Repository repository) {
        this.repo = repository;
    }

    public List<ListItem> list(ListParams params) {
        try {
            return repo.list(params);
        } catch (SQLException x) {
            throw new RuntimeException(x);
        }
    }

    public Pursuit getById(int id) {
        try {
            return repo.getById(id);
        } catch (SQLException x) {
            throw new RuntimeException(x);
        }
    }

    public boolean update(UpdatePayload payload) {
        if (!payload.isValid())
            throw new InvalidPayload("invalid payload.");
        try {
            var count = repo.update(payload);
            return count > 0;
        } catch (SQLException x) {
            throw new RuntimeException(x);
        }
    }

}
