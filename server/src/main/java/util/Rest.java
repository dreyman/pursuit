package util;

import io.javalin.http.Context;

import java.util.Optional;

public class Rest {

public static Optional<Integer> getId(Context ctx) {
    var id_param = ctx.pathParam("id");
    try {
        var id = Integer.parseInt(id_param);
        return Optional.of(id);
    } catch (NumberFormatException _) {
        return Optional.empty();
    }
}

private Rest() {}

}
