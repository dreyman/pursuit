package pursuit;

import com.google.gson.*;
import io.javalin.Javalin;
import io.javalin.http.Handler;
import io.javalin.http.UnprocessableContentResponse;
import io.javalin.json.JsonMapper;
import io.javalin.plugin.bundled.CorsPluginConfig;
import io.javalin.util.FileUtil;
import org.jetbrains.annotations.NotNull;
import pursuit.model.Bike;

import java.io.File;
import java.io.FileInputStream;
import java.lang.reflect.Type;
import java.time.Instant;

import static io.javalin.http.HttpStatus.NOT_FOUND;

public class Main {

    public static void main(String[] args) {
        var crud = new Crud();
        var storage = new Storage();

        var app = Javalin.create(config -> {
                            config.bundledPlugins
                                    .enableCors(cors -> cors.addRule(CorsPluginConfig.CorsRule::anyHost));
                            config.jsonMapper(gsonMapper());
                        }
                )
                .get("/api/hello", ctx -> ctx.result("{\"hello\": \"there\"}"))
                .get("/api/routes", ctx -> {
                    ctx.json(crud.getRoutes());
                })
                .get("/api/routes/{id}", ctx -> {
                    try {
                        var id = Integer.parseInt(ctx.pathParam("id"));
                        var route = crud.getRoute(id);
                        ctx.json(route);
                    } catch (NumberFormatException x) {
                        ctx.status(NOT_FOUND);
                    }
                })
                .get("/api/routes/{id}/track", ctx -> {
                    try {
                        var id = Integer.parseInt(ctx.pathParam("id"));
                        var trackFile = storage.getTrackFile(id);
                        if (trackFile.exists()) {
                            ctx.result(new FileInputStream(trackFile));
                        } else {
                            ctx.status(NOT_FOUND);
                        }
                    } catch (NumberFormatException x) {
                        ctx.status(NOT_FOUND);
                    }
                })
                .post("/api/bikes", ctx -> {
                    // FIXME validation
                    var bike = ctx.bodyAsClass(Bike.class);
                    bike = crud.createBike(bike);
                    ctx.json(bike);
                })
                .post("/api/upload", ctx -> {
                    var file = ctx.uploadedFile("file");
                    if (file == null)
                        throw new UnprocessableContentResponse();
                    var path = "/home/ihor/.wild-fields/temp/" + file.filename();
                    FileUtil.streamToFile(file.content(), path);

                    var route = crud.importFromFile(path);
                    new File(path).delete(); // fixme handle error
                    if (route != null) ctx.json(route);
                    else ctx.status(500);
                })
                .get("/api/bikes", ctx -> {
                    ctx.json(crud.getBikes());
                })
                .start(7070);
    }

    static JsonMapper gsonMapper() {
        Gson gson = new GsonBuilder()
                .registerTypeAdapter(Instant.class, (JsonSerializer<Instant>) (src, _, _)
                        -> new JsonPrimitive(Long.toString(src.getEpochSecond())))
                .create();
        return new JsonMapper() {
            @NotNull
            public String toJsonString(@NotNull Object obj, @NotNull Type type) {
                return gson.toJson(obj, type);
            }

            @NotNull
            public <T> T fromJsonString(@NotNull String json, @NotNull Type targetType) {
                return gson.fromJson(json, targetType);
            }
        };
    }

//    static Handler listActivities = ctx -> {
//        var dirs = new File("/home/ihor/.wild-fields/").listFiles(File::isDirectory);
//        if (dirs == null) {
//            ctx.result("[]");
//            return;
//        }
//        ctx.json(Arrays.stream(dirs).map(File::getName).collect(toList()));
//    };

//    static Handler route = ctx -> {
//        try {
//            var id = Integer.parseInt(ctx.pathParam("id"));
//            var route = new File("/home/ihor/.wild-fields/" + id + "/track");
//            if (route.exists()) ctx.result(new FileInputStream(route));
//            else ctx.status(NOT_FOUND);
//            ctx.contentType(ContentType.APPLICATION_OCTET_STREAM);
//
//        } catch (NumberFormatException x) {
//            ctx.status(NOT_FOUND);
//        }
//    };

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
