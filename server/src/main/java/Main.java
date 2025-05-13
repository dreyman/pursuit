import api.ErrorResponse;
import api.InvalidPayload;
import api.InvalidRequest;
import com.google.gson.*;
import io.javalin.Javalin;
import io.javalin.config.JavalinConfig;
import io.javalin.http.ContentType;
import io.javalin.http.UnprocessableContentResponse;
import io.javalin.http.staticfiles.Location;
import io.javalin.json.JsonMapper;
import io.javalin.plugin.bundled.CorsPluginConfig;
import io.javalin.router.JavalinDefaultRoutingApi;
import io.javalin.util.FileUtil;
import location.Flyby;
import org.jetbrains.annotations.NotNull;
import pursuit.Query;
import pursuit.Payload;
import stats.RecalcRequest;

import java.io.File;
import java.io.FileInputStream;
import java.lang.reflect.Type;
import java.nio.file.Path;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;

import static io.javalin.http.HttpStatus.*;

public class Main {

    public static void main(String[] args) {
        App app;
        try {
            app = App.initFromArgs(args);
        } catch (RuntimeException x) {
            System.err.println("Error: " + x.getMessage());
            x.printStackTrace();
            return;
        }
        var javalin = Javalin.create(Main::javalinConfig);
        initApiEndpoints(javalin, app);
        initExceptionMapping(javalin);
        javalin.start(7070);
    }

    static void initApiEndpoints(JavalinDefaultRoutingApi<Javalin> api,
                                 App app) {
        api.get("/api/hello", ctx -> {
            ctx.contentType(ContentType.JSON);
            ctx.result("{\"hello\":\"there\"}");
        });
//        api.post("/api/migrate", ctx -> {
//            var migration = new Migration();
//            migration.migrate(app.landmarksApi);
//
//            ctx.status(200);
//        });

        api.get("/api/medium", ctx -> {
            var list = app.medium_api.query();
            ctx.json(list);
        });
        api.post("/api/medium/new", ctx -> {
            try {
                var payload = ctx.bodyAsClass(medium.CreatePayload.class);
                var new_medium = app.medium_api.create(payload);
                ctx.json(new_medium);
            } catch (IllegalArgumentException x) {
                ctx.status(UNPROCESSABLE_CONTENT);
                ctx.json(new ErrorResponse("Invalid 'kind' value."));
            } catch (InvalidRequest x) {
                ctx.status(UNPROCESSABLE_CONTENT);
                ctx.json(new ErrorResponse(x.getMessage()));
            }
        });
        api.get("/api/medium/{id}", ctx -> {
            try {
                var id = Integer.parseInt(ctx.pathParam("id"));
                var medium = app.medium_api.getStats(id);
                if (medium == null) {
                    ctx.status(NOT_FOUND);
                    return;
                }
                ctx.json(medium);
            } catch (NumberFormatException x) {
                ctx.status(NOT_FOUND);
            }
        });

        api.get("/api/pursuit", ctx -> {
            try {
                var params = new Query(ctx.queryParamMap());
                var list = app.pursuit_api.query(params);
                ctx.json(list);
            } catch (api.InvalidRequest x) {
                ctx.status(UNPROCESSABLE_CONTENT);
                ctx.json(new api.ErrorResponse(x.getMessage()));
            }
        });
        api.get("/api/pursuit/{id}", ctx -> {
            try {
                var id = Integer.parseInt(ctx.pathParam("id"));
                var pursuit = app.pursuit_api.getById(id);
                if (pursuit == null) {
                    ctx.status(NOT_FOUND);
                    return;
                }
                ctx.json(pursuit);
            } catch (NumberFormatException x) {
                ctx.status(NOT_FOUND);
            }
        });
        api.put("/api/pursuit/{id}", ctx -> {
            try {
                var id = Integer.parseInt(ctx.pathParam("id"));
                var payload = ctx.bodyAsClass(Payload.class);
                var updated = app.pursuit_api.update(id, payload);
                if (!updated) {
                    ctx.status(NOT_FOUND);
                }
            } catch (NumberFormatException x) {
                ctx.status(NOT_FOUND);
            } catch (IllegalArgumentException x) {
                ctx.status(UNPROCESSABLE_CONTENT);
                ctx.json(new ErrorResponse("Invalid 'kind' value."));
            }
        });

        api.post("/api/gpsfile", ctx -> {
            var file = ctx.uploadedFile("file");
            if (file == null)
                throw new UnprocessableContentResponse();
            var path = Path.of(app.temp_dir, file.filename()).toString();
            FileUtil.streamToFile(file.content(), path);

            try {
                var pursuit = app.importFile(path);
                ctx.json(pursuit);
            } finally {
                var deleted = new File(path).delete();
                // fixme proper logging
                if (!deleted)
                    System.out.printf("Failed to delete temp file: %s", path);
            }
        });
        api.get("/api/pursuit/{id}/track", ctx -> {
            try {
                var id = Integer.parseInt(ctx.pathParam("id"));
                var track_file = app.getTrackFile(id);
                if (track_file.exists()) {
                    ctx.result(new FileInputStream(track_file));
                } else {
                    ctx.status(NOT_FOUND);
                }
            } catch (NumberFormatException x) {
                ctx.status(NOT_FOUND);
            }
        });
        api.put("/api/pursuit/{id}/stats", ctx -> {
            try {
                var id = Integer.parseInt(ctx.pathParam("id"));
                var req = RecalcRequest.fromJson(ctx.body());
                var stats = app.stats_api.recalcStats(
                        id,
                        req.min_speed,
                        req.max_time_gap
                );
                ctx.json(stats);
                ctx.status(OK);
            } catch (NumberFormatException x) {
                ctx.status(NOT_FOUND);
            }
        });

        api.get("/api/landmarks/list", ctx -> {
            var landmarks = app.landmarks_api.query();
            ctx.json(landmarks);
        });
        api.get("/api/landmarks/{id}", ctx -> {
            try {
                var id = Integer.parseInt(ctx.pathParam("id"));
                var lm = app.landmarks_api.getById(id);
                if (lm == null) {
                    ctx.status(NOT_FOUND);
                    return;
                }
                ctx.json(lm);
            } catch (NumberFormatException x) {
                ctx.status(NOT_FOUND);
            }
        });
        api.post("/api/landmarks/new", ctx -> {
            int id = app.landmarks_resp_api.create(ctx.body());
            var resp_body = new HashMap<String, Integer>(1);
            resp_body.put("id", id);
            ctx.json(resp_body);
            ctx.status(OK);
        });
        api.delete("/api/landmarks/{id}", ctx -> {
            try {
                var id = Integer.parseInt(ctx.pathParam("id"));
                var deleted = app.landmarks_api.delete(id);
                if (!deleted) {
                    ctx.status(NOT_FOUND);
                    return;
                }
                ctx.json("{}");
                ctx.status(OK);
            } catch (NumberFormatException x) {
                ctx.status(NOT_FOUND);
            }
        });

        api.get("/api/photos/list", ctx -> {
            var photos = app.photos_api.query();
            ctx.json(photos);
        });
        api.get("/api/photos/{id}", ctx -> {
            try {
                var id = Integer.parseInt(ctx.pathParam("id"));
                var photo = app.photos_api.getById(id);
                if (photo == null) {
                    ctx.status(NOT_FOUND);
                    return;
                }
                ctx.json(photo);
            } catch (NumberFormatException x) {
                ctx.status(NOT_FOUND);
            }
        });
        api.get("/api/photos/{id}/file", ctx -> {
            try {
                var id = Integer.parseInt(ctx.pathParam("id"));
                var photo = app.photos_api.getById(id);
                if (photo == null) {
                    ctx.status(NOT_FOUND);
                    return;
                }
                var file = new File(photo.file);
                ctx.result(new FileInputStream(file));
            } catch (NumberFormatException x) {
                ctx.status(NOT_FOUND);
            }
        });

        api.post("/api/location/flybys", ctx -> {
            var query = location.Query.fromJson(ctx.body());
            List<Flyby> flybys = app.location_api.locationFlybys(query);
            ctx.json(flybys);
        });

        api.get("/api/*", ctx -> ctx.status(NOT_FOUND));
    }

    static void initExceptionMapping(JavalinDefaultRoutingApi<Javalin> javalin) {
        javalin.exception(api.InternalError.class, (e, ctx) -> {
            // fixme properly log error
            System.out.println(e.getMessage());
            ctx.status(INTERNAL_SERVER_ERROR);
        });
        javalin.exception(api.InvalidRequest.class, (e, ctx) -> {
            ctx.status(UNPROCESSABLE_CONTENT);
            ctx.json(new ErrorResponse(e.getMessage()));
        });
        javalin.exception(InvalidPayload.class, (e, ctx) -> {
           ctx.status(UNPROCESSABLE_CONTENT);
           ctx.json(e.invalid_fields);
        });
    }

    static void javalinConfig(JavalinConfig config) {
        config.bundledPlugins
                .enableCors(cors -> cors.addRule(CorsPluginConfig.CorsRule::anyHost));
        config.jsonMapper(gsonMapper());

        config.showJavalinBanner = false;

        config.spaRoot.addFile("/", "webapp/200.html", Location.EXTERNAL);
        config.staticFiles.add(staticFiles -> {
            staticFiles.hostedPath = "/";
            staticFiles.directory = "webapp";
            staticFiles.location = Location.EXTERNAL;
        });
    }

    static JsonMapper gsonMapper() {
        Gson gson = new GsonBuilder()
                .registerTypeAdapter(Instant.class,
                        (JsonSerializer<Instant>) (src, _, _)
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
