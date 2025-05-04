package pursuit;

import api.InvalidRequest;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class Query {
    public static final int max_limit = 50;
    public static final int default_limit = 25;
    public static final String default_order_by_field = "start_time";
    public static final String default_order = "DESC";

    public Pursuit.Kind kind;
    public Integer medium;
    public Integer distance_km_min;
    public Integer distance_km_max;
    public List<Integer> ids;

    public String order_by_field = default_order_by_field;
    public String order = default_order;
    public int limit = default_limit;

    public Query() {}

    public Query(Map<String, List<String>> params) {
        var limit = getUintParam(params, "limit");
        this.limit = limit == null ? default_limit : Math.min(limit, max_limit);

        var kind_param = firstOrNull(params.get("kind"));
        if (kind_param != null) {
            try {
                this.kind = Pursuit.Kind.valueOf(kind_param);
            } catch (IllegalArgumentException x) {
                var valid_vals = Arrays.stream(Pursuit.Kind.values())
                        .map(Enum::toString)
                        .collect(Collectors.joining(", "));
                throw new api.InvalidRequest("Invalid 'kind' param value. Valid values: " + valid_vals);
            }
        }

        this.medium = getUintParam(params, "medium");
        this.distance_km_min = getUintParam(params, "distance_min");
        this.distance_km_max = getUintParam(params, "distance_max");
    }

    public String buildSql() {
        var sql = new StringBuilder();

        var where = new StringBuilder();
        if (this.kind != null) {
            where.append("kind = ").append(this.kind.ordinal());
        }
        if (this.medium != null) {
            if (!where.isEmpty()) where.append(" AND ");
            where.append("medium_id = ").append(this.medium);
        }
        if (this.distance_km_min != null) {
            if (!where.isEmpty()) where.append(" AND ");
            where.append("distance >= ").append(this.distance_km_min * 1000);
        }
        if (this.distance_km_max != null) {
            if (!where.isEmpty()) where.append(" AND ");
            where.append("distance <= ").append(this.distance_km_max * 1000);
        }
        if (this.ids != null && !this.ids.isEmpty()) {
            if (!where.isEmpty()) where.append(" AND ");
            where.append("id IN (");
            for (int i = 0; i < this.ids.size(); i++) {
                where.append(this.ids.get(i));
                if (i < this.ids.size() - 1) where.append(", ");
            }
            where.append(")");
        }

        if (!where.isEmpty())
            sql.append(" WHERE ").append(where);
        sql.append(" ORDER BY ")
                .append(this.order_by_field)
                .append(" ")
                .append(this.order);
        sql.append(" LIMIT ").append(this.limit);

        return sql.toString();
    }

    static Integer getUintParam(Map<String, List<String>> params, String param_name) {
        var param_str = firstOrNull(params.get(param_name));
        if (param_str == null) return null;
        try {
            var param_val = Integer.parseInt(param_str);
            if (param_val <= 0)
                throw InvalidRequest.invalidUintParam(param_name);
            return param_val;
        } catch (NumberFormatException x) {
            throw InvalidRequest.invalidUintParam(param_name);
        }
    }

    static String firstOrNull(List<String> values) {
        if (values == null || values.isEmpty())
            return null;
        return values.get(0);
    }
}
