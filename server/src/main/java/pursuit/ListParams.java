package pursuit;

import api.CommonParams;
import api.Exceptions;
import api.InvalidRequest;
import api.ApiRequest;
import io.javalin.http.Context;

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class ListParams implements ApiRequest {

    public static final int max_limit = 30;
    public static final int default_limit = 15;
    public static final String[] order_by_fields =
            new String[]{"start_time", "avg_speed", "distance", "avg_travel_speed"};

    public Pursuit.Kind kind;
    public Integer min_distance;
    public Integer max_distance;

    public CommonParams common;

    public ListParams(Map<String, List<String>> query_params) {
        this.common = new CommonParams(default_limit, max_limit, order_by_fields, query_params);

        var kind_param = firstOrNull(query_params.get("kind"));
        if (kind_param != null) {
            try {
                this.kind = Pursuit.Kind.valueOf(kind_param);
            } catch (IllegalArgumentException x) {
                var valid_vals = Arrays.stream(Pursuit.Kind.values())
                        .map(Enum::toString)
                        .collect(Collectors.joining(", "));
                throw new InvalidRequest("Invalid 'kind' param value. Valid values: " + valid_vals);
            }
        }

        var min_distance_param = firstOrNull(query_params.get("min_distance"));
        if (min_distance_param != null) {
            try {
                this.min_distance = Integer.parseInt(min_distance_param);
                if (this.min_distance < 0)
                    throw Exceptions.invalidUintParam("min_distance");
            } catch (NumberFormatException x) {
                throw Exceptions.invalidUintParam("min_distance");
            }
        }

        var max_distance_param = firstOrNull(query_params.get("max_distance"));;
        if (max_distance_param != null) {
            try {
                this.max_distance = Integer.parseInt(max_distance_param);
                if (this.max_distance < 0)
                    throw Exceptions.invalidUintParam("max_distance");
            } catch (NumberFormatException x) {
                throw Exceptions.invalidUintParam("max_distance");
            }
        }
    }

    @Override
    public String buildQuery(String select_query) {
        var q = new StringBuilder(select_query);

        var where = new StringBuilder();

        if (kind != null) where.append("kind = ?");
        if (min_distance != null) {
            if (!where.isEmpty()) where.append(" and ");
            where.append("distance > ?");
        }

        if (max_distance != null) {
            if (!where.isEmpty()) where.append(" and ");
            where.append("distance < ?");
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
        if (kind != null) s.setInt(++i, kind.ordinal());
        if (min_distance != null) s.setInt(++i, min_distance * 1000);
        if (max_distance != null) s.setInt(++i, max_distance * 1000);
    }

    String firstOrNull(List<String> values) {
        if (values == null || values.isEmpty())
            return null;
        return values.get(0);
    }
}
