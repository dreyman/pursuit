package api;

import io.javalin.http.Context;

import java.util.List;
import java.util.Map;

public class CommonParams {

    public int default_limit;
    public int max_limit;
    public String[] order_by_fields;
    InvalidRequest invalid_order_by_param;

    public int limit;
    public String order_by;
    public boolean desc = true;

    public CommonParams(int default_limit,
                        int max_limit,
                        String[] order_by_fields,
                        Map<String, List<String>> query_params) {
        this.default_limit = default_limit;
        this.max_limit = max_limit;
        this.limit = default_limit;
        this.order_by_fields = order_by_fields;
        this.invalid_order_by_param = new InvalidRequest("Invalid 'order_by' value. Valid values: "
                + String.join(",", order_by_fields));

        var limit_param = firstOrNull(query_params.get("limit"));
        if (limit_param != null) {
            try {
                var limit = Integer.parseInt(limit_param);
                if (limit < 1) throw Exceptions.invalidUintParam("limit");
                this.limit = Math.min(limit, max_limit);
            } catch (NumberFormatException x) {
                throw Exceptions.invalidUintParam("limit");
            }
        }

        var order_by_param = firstOrNull(query_params.get("order_by"));
        if (order_by_param != null) {
            var order_by = findOrderByField(order_by_param);
            if (order_by == null) throw invalid_order_by_param;
            this.order_by = order_by;
            this.desc = Boolean.parseBoolean(firstOrNull(query_params.get("desc")));
        }
    }

    public String orderByQuery() {
        if (order_by != null) {
            return "ORDER BY " + order_by + " " + (desc ? "DESC" : "ASC");
        }
        return null;
    }

    String findOrderByField(String val) {
        for (String field : order_by_fields) {
            if (field.equals(val)) return field;
        }
        return null;
    }

    String firstOrNull(List<String> values) {
        if (values == null || values.isEmpty())
            return null;
        return values.get(0);
    }

}
