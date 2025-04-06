package pursuit;

import api.InvalidRequest;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class QueryParams {
    public static final int max_limit = 50;
    public static final int default_limit = 15;
    public static final String default_order_by_field = "start_time";
    public static final String default_order = "DESC";

    public Pursuit.Kind kind;

    public String order_by_field = default_order_by_field;
    public String order = default_order;
    public int limit = default_limit;

    public QueryParams(Map<String, List<String>> params) {
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

        var limit_param = firstOrNull(params.get("limit"));
        if (limit_param != null) {
            try {
                this.limit = Math.min(Integer.parseInt(limit_param), max_limit);
            } catch (NumberFormatException x) {
                throw InvalidRequest.invalidUintParam("limit");
            }
        }
    }

    String firstOrNull(List<String> values) {
        if (values == null || values.isEmpty())
            return null;
        return values.get(0);
    }
}
