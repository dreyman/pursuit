package pursuit;

import api.InvalidRequest;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class QueryParams {
    public static final int max_limit = 50;
    public static final int default_limit = 25;
    public static final String default_order_by_field = "start_time";
    public static final String default_order = "DESC";

    public Pursuit.Kind kind;
    public Integer medium;
    public Integer distance_min;
    public Integer distance_max;

    public String order_by_field = default_order_by_field;
    public String order = default_order;
    public int limit = default_limit;

    public QueryParams() {}

    public QueryParams(Map<String, List<String>> params) {
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
        this.distance_min = getUintParam(params, "distance_min");
        this.distance_max = getUintParam(params, "distance_max");
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
