package fields.wild;

import io.javalin.Javalin;
import io.javalin.http.Handler;
import io.javalin.plugin.bundled.CorsPluginConfig;

import java.io.File;
import java.io.FileInputStream;
import java.util.Arrays;

import static io.javalin.http.HttpStatus.NOT_FOUND;
import static java.util.stream.Collectors.toList;

public class Main {
    public static void main(String[] args) {
        var app = Javalin.create(config ->
                        config.bundledPlugins
                                .enableCors(cors -> cors.addRule(CorsPluginConfig.CorsRule::anyHost))
                )
                .get("list", listActivities)
                .get("/{id}/route", route)
                .get("/hello", ctx -> ctx.result("{\"hello\": \"there\"}"))
                .start(7070);
    }

    static Handler listActivities = ctx -> {
        var dirs = new File("/home/ihor/.wild-fields/").listFiles(File::isDirectory);
        if (dirs == null) {
            ctx.result("[]");
            return;
        }
        ctx.json(Arrays.stream(dirs).map(File::getName).collect(toList()));
    };

    static Handler route = ctx -> {
        try {
            var id = Integer.parseInt(ctx.pathParam("id"));
            var route = new File("/home/ihor/.wild-fields/" + id + "/route");
            if (route.exists()) ctx.result(new FileInputStream(route));
            else ctx.status(NOT_FOUND);
//            ctx.contentType(ContentType.APPLICATION_OCTET_STREAM);

        } catch (NumberFormatException x) {
            ctx.status(NOT_FOUND);
        }
    };
}
