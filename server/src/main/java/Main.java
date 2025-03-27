import app.ErrorResponse;
import api.InvalidRequest;
import com.google.gson.*;
import io.javalin.Javalin;
import io.javalin.json.JsonMapper;
import io.javalin.plugin.bundled.CorsPluginConfig;
import org.jetbrains.annotations.NotNull;

import java.lang.reflect.Type;
import java.time.Instant;

public class Main {
    final static String db_file = "/home/ihor/.pursuit/pursuit.db";

    public static void main(String[] args) {
//        var crud = new Crud();
//        var storage = new Storage();
        var mediumRepo = new medium.Repository(db_file);
        var mediumApi = new medium.Api(mediumRepo);

        var pursuitRepo = new pursuit.Repository(db_file);
        var pursuitApi = new pursuit.Api(pursuitRepo);

        var javalin_app = Javalin.create(config -> {
                            config.bundledPlugins
                                    .enableCors(cors -> cors.addRule(CorsPluginConfig.CorsRule::anyHost));
                            config.jsonMapper(gsonMapper());
                        }
                )
                .get("/api/hello", ctx -> ctx.result("{\"hello\": \"there\"}"))
                .get("/api/medium", ctx -> {
                    try {
                        var req = new medium.ListParams(ctx.queryParamMap());
                        var list = mediumApi.list(req);
                        ctx.json(list);
                    } catch (InvalidRequest x) {
                        ctx.status(422);
                        ctx.json(new ErrorResponse(x.getMessage()));
                    }
                })
                .get("/api/pursuit", ctx -> {
                    try {
                        var req = new pursuit.ListParams(ctx.queryParamMap());
                        var list = pursuitApi.list(req);
                        ctx.json(list);
                    } catch (InvalidRequest x) {
                        ctx.status(422);
                        ctx.json(new ErrorResponse(x.getMessage()));
                    }
                })
//                .get("/api/routes", ctx -> {
//                    ctx.json(crud.getRoutes());
//                })
//                .get("/api/routes/{id}", ctx -> {
//                    try {
//                        var id = Integer.parseInt(ctx.pathParam("id"));
//                        var pursuit = crud.getPursuit(id);
//                        ctx.json(pursuit);
//                    } catch (NumberFormatException x) {
//                        ctx.status(NOT_FOUND);
//                    }
//                })
//                .get("/api/routes/{id}/track", ctx -> {
//                    try {
//                        var id = Integer.parseInt(ctx.pathParam("id"));
//                        var trackFile = storage.getTrackFile(id);
//                        if (trackFile.exists()) {
//                            ctx.result(new FileInputStream(trackFile));
//                        } else {
//                            ctx.status(NOT_FOUND);
//                        }
//                    } catch (NumberFormatException x) {
//                        ctx.status(NOT_FOUND);
//                    }
//                })
//                .post("/api/bikes", ctx -> {
//                    // FIXME validation
//                    var bike = ctx.bodyAsClass(Bike.class);
//                    bike = crud.createBike(bike);
//                    ctx.json(bike);
//                })
//                .post("/api/upload", ctx -> {
//                    var file = ctx.uploadedFile("file");
//                    if (file == null)
//                        throw new UnprocessableContentResponse();
//                    var path = "/home/ihor/.pursuit/temp/" + file.filename();
//                    FileUtil.streamToFile(file.content(), path);
//
//                    var pursuit = crud.importFromFile(path);
//                    new File(path).delete(); // fixme handle error
//                    ctx.json(pursuit);
//                })
//                .get("/api/bikes", ctx -> {
//                    ctx.json(crud.getBikes());
//                })
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

}
