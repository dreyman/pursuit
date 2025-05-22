import api.ErrorResponse;
import api.InvalidPayload;
import api.InvalidRequest;
import com.google.gson.*;
import io.javalin.Javalin;
import io.javalin.config.JavalinConfig;
import io.javalin.http.ContentType;
import io.javalin.http.Context;
import io.javalin.http.NotFoundResponse;
import io.javalin.http.UnprocessableContentResponse;
import io.javalin.http.staticfiles.Location;
import io.javalin.json.JsonMapper;
import io.javalin.plugin.bundled.CorsPluginConfig;
import io.javalin.router.JavalinDefaultRoutingApi;
import io.javalin.util.FileUtil;
import location.Flyby;
import org.jetbrains.annotations.NotNull;
import photos.TagPayload;
import pursuit.UpdatePayload;
import pursuit.Query;
import stats.RecalcRequest;

import java.io.File;
import java.io.FileInputStream;
import java.lang.reflect.Type;
import java.nio.file.Path;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;

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
            var payload = ctx.bodyAsClass(UpdatePayload.class);
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

//    api.get("/api/landmarks/list", ctx -> ctx.json(
//            app.landmarks_api.list()
//    ));
//    api.get("/api/landmarks/{id}", ctx -> ctx.json(
//            app.landmarks_api.getById(
//                    getIdPathParam(ctx).orElseThrow(NotFoundResponse::new)
//            ).orElseThrow(NotFoundResponse::new)
//    ));
//    api.post("/api/landmarks/new", ctx -> ctx.json(
//            Map.of("id", app.landmarks_api.create(ctx.body()))
//    ));
//    api.delete("/api/landmarks/{id}", ctx -> ctx.status(
//            app.landmarks_api.delete(
//                    getIdPathParam(ctx).orElseThrow(NotFoundResponse::new)
//            ) ? OK : NOT_FOUND
//    ));
    app.landmarks_api.initJavalin(api, "/api/landmarks");

    api.get("/api/photos/list", ctx -> {
        var photos = app.photos_api.query();
        ctx.json(photos);
    });
    api.get("/api/photos/{id}", ctx -> {
        var id = getIdPathParam(ctx).orElseThrow(NotFoundResponse::new);
        var photo = app.photos_api.getById(id);
        if (photo == null) {
            ctx.status(NOT_FOUND);
            return;
        }
        JsonElement el = app.gson.toJsonTree(photo);
        var tags = app.photos_api.getTags(id);
        el.getAsJsonObject().add("tags", app.gson.toJsonTree(tags));
        var json = el.toString();
        ctx.result(json);
        ctx.contentType(ContentType.APPLICATION_JSON);
    });
    api.post("/api/photos/{id}/tags", ctx -> {
        var photo_id = getIdPathParam(ctx).orElseThrow(NotFoundResponse::new);
        var tag = ctx.bodyAsClass(TagPayload.class);
        if (tag.id != null) {
            app.photos_api.addTag(photo_id, tag.id);
            ctx.json(Map.of("id", tag.id));
            ctx.status(OK);
        } else if (tag.name != null) {
            var tag_id = app.photos_api.addTag(photo_id, tag.name);
            var resp = Map.of("id", tag_id);
            ctx.json(resp);
        } else
            ctx.status(UNPROCESSABLE_CONTENT);
    });
    api.get("/api/photos/{id}/file", ctx -> {
        var id = getIdPathParam(ctx).orElseThrow(NotFoundResponse::new);
        var photo = app.photos_api.getById(id);
        if (photo == null) {
            ctx.status(NOT_FOUND);
            return;
        }
        var file = new File(photo.file);
        ctx.result(new FileInputStream(file));
    });
    api.get("/api/tags/list", ctx -> {
        var tags = app.tag_repo.list();
        ctx.json(tags);
    });


    api.post("/api/location/flybys", ctx -> {
        var query = location.Query.fromJson(ctx.body());
        List<Flyby> flybys = app.location_api.locationFlybys(query);
        ctx.json(flybys);
    });

    api.get("/api/*", ctx -> ctx.status(NOT_FOUND));
}

static Optional<Integer> getIdPathParam(Context ctx) {
    var id_param = ctx.pathParam("id");
    try {
        var id = Integer.parseInt(id_param);
        return Optional.of(id);
    } catch (NumberFormatException _) {
        return Optional.empty();
    }
}

static void initExceptionMapping(JavalinDefaultRoutingApi<Javalin> javalin) {
    javalin.exception(api.InternalError.class, (e, ctx) -> {
        // fixme properly log error
        System.out.println(e.getMessage());
        ctx.status(500);
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
    config.pvt.javaLangErrorHandler((response, error) -> {
        if (error instanceof AssertionError) {
            // fixme proper logging
            System.out.println("Assertion error: " + error.getStackTrace()[0]);
        } else {
            System.out.println(error.getClass().getName());
            System.out.println(error.getMessage());
            System.out.println(error.getStackTrace()[0]);
        }
        response.setStatus(500);
    });

    config.bundledPlugins.enableCors(cors ->
            cors.addRule(CorsPluginConfig.CorsRule::anyHost)
    );
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
