package medium;

import api.ApiRequest;
import api.CommonParams;

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class ListParams implements ApiRequest {

    public static final String[] order_by_fields =
            new String[]{"distance", "time", "created_at"};
    public static final int max_limit = 100;
    public static final int default_limit = 25;

    public String kind;
    public Boolean archived = false;

    public CommonParams common;

    public ListParams(Map<String, List<String>> query_params) {
        this.common = new CommonParams(default_limit, max_limit, order_by_fields, query_params);

        this.kind = firstOrNull(query_params.get("kind"));

        var archived_param = firstOrNull(query_params.get("archived"));
        if (archived_param != null)
            this.archived = Boolean.parseBoolean(archived_param);
    }

    @Override
    public String buildQuery(String select_query) {
        var q = new StringBuilder(select_query);

        var where = new StringBuilder();
        if (kind != null) where.append("kind = ?");
        if (archived != null) {
            if (!where.isEmpty()) where.append(" and ");
            where.append("archived = ?");
        }
        if (!where.isEmpty()) q.append(" WHERE ").append(where);

        var order_by = common.orderByQuery();
        if (order_by != null) {
            q.append(" ").append(order_by);
        }

        q.append(" ").append("LIMIT ").append(common.limit);

        return q.toString();
    }

    @Override
    public void setArgs(PreparedStatement s) throws SQLException {
        var i = 0;
        if (kind != null) s.setString(++i, kind);
        if (archived != null) s.setBoolean(++i, archived);
    }

    String firstOrNull(List<String> values) {
        if (values == null || values.isEmpty())
            return null;
        return values.get(0);
    }

}
