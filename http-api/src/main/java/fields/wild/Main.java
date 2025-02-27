package fields.wild;

import fields.wild.storage.SqliteStorage;
import io.javalin.Javalin;
import io.javalin.http.ContentType;
import io.javalin.http.Handler;
import io.javalin.plugin.bundled.CorsPluginConfig;
import io.javalin.util.FileUtil;

import java.io.File;
import java.io.FileInputStream;
import java.util.Arrays;

import static io.javalin.http.HttpStatus.NOT_FOUND;
import static io.javalin.http.HttpStatus.OK;
import static java.util.stream.Collectors.toList;

public class Main {

    public static void main(String[] args) {
        Service service = new Service(new SqliteStorage("/home/ihor/.wild-fields/wf.db"));

        var app = Javalin.create(config ->
                        config.bundledPlugins
                                .enableCors(cors -> cors.addRule(CorsPluginConfig.CorsRule::anyHost))
                )
                .get("list", listActivities)
//                .get("test/{id}", ctx -> {
//                    try {
//                        int id = Integer.parseInt(ctx.pathParam("id"));
//                        try {
//                            var name = service.testName(id);
//                            if (name != null)
//                                ctx.result(String.format("{\"name\": \"%s\"}", name));
//                            else {
//                                ctx.status(NOT_FOUND);
//                                ctx.result("{\"error\":\"not found\"}");
//                            }
//                        } catch (Exception x) {
//                            ctx.status(500);
//                            ctx.result("{\"error\":\"something went wrong\"}");
//                        }
//                    } catch (NumberFormatException x) {
//                        ctx.status(NOT_FOUND);
//                    }
//                })
                .get("/{id}/route", route)
                .get("/hello", ctx -> ctx.result("{\"hello\": \"there\"}"))
                .post("/upload", ctx -> {
                    var file = ctx.uploadedFile("file");
                    if (file != null) {
                        var path = "/home/ihor/.wild-fields/temp/" + file.filename();
                        FileUtil.streamToFile(file.content(), path);
                        int id = service.importEntry(path);
                        ctx.result(String.format("{\"id\":%d,\"status\":\"in_progress\"}", id));
                    }
                })
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
            ctx.contentType(ContentType.APPLICATION_OCTET_STREAM);

        } catch (NumberFormatException x) {
            ctx.status(NOT_FOUND);
        }
    };

//    static Handler uploadHandler = ctx -> {
//        var file = ctx.uploadedFile("file");
//        if (file != null) {
//            var path = "/home/ihor/.wild-fields/temp/" + file.filename();
//            FileUtil.streamToFile(file.content(), path);
//
//        }
//    };

    static Handler testHandler = ctx -> {

    };
}
