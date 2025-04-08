package medium;

import api.InvalidRequest;

import java.sql.SQLException;
import java.util.List;

public class Api {
    Repository repo;
    pursuit.Api pursuitApi;

    public Api(String sqlite_db_file, pursuit.Api pursuitApi) {
        repo = new Repository(sqlite_db_file);
        this.pursuitApi = pursuitApi;
    }

    public List<Medium> query() {
        try {
            return repo.list();
        } catch (SQLException x) {
            return List.of();
        }
    }

    public Medium getById(int id) {
        try {
            return repo.getById(id);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public MediumStats getStats(int id) {
        try {
            var medium = repo.getStats(id);
            if (medium == null) return null;
            var params = new pursuit.QueryParams();
            params.medium = medium.id;
            params.limit = 25;
            medium.last_pursuits = pursuitApi.query(params);
            return medium;
        } catch (SQLException x) {
            throw new RuntimeException(x);
        }
    }

    public Medium create(medium.CreatePayload payload) {
        try {
            var err = payload.validate();
            if (err != null) throw new InvalidRequest(err);
            int id = repo.insert(payload);
            if (id == 0) {
                throw new RuntimeException("Something went wrong.");
            }
            return getById(id);
        } catch (SQLException x) {
            throw new RuntimeException(x);
        }
    }
}
