import com.google.gson.*;
import io.javalin.Javalin;
import io.javalin.config.JavalinConfig;
import io.javalin.http.ContentType;
import io.javalin.http.UnprocessableContentResponse;
import io.javalin.json.JsonMapper;
import io.javalin.plugin.bundled.CorsPluginConfig;
import io.javalin.router.JavalinDefaultRoutingApi;
import io.javalin.util.FileUtil;
import org.jetbrains.annotations.NotNull;
import pursuit.QueryParams;
import pursuit.UpdatePayload;

import java.io.FileInputStream;
import java.lang.reflect.Type;
import java.time.Instant;

import static io.javalin.http.HttpStatus.NOT_FOUND;

public class Main {

    public static void main(String[] args) {
        var app = new App();
        var javalin = Javalin.create(Main::config);
        initApiEndpoints(javalin, app);
        javalin.start(7070);
    }

    static void initApiEndpoints(JavalinDefaultRoutingApi<Javalin> api,
                                 App app) {
        api.get("/api/hello", ctx -> {
            ctx.contentType(ContentType.JSON);
            ctx.result("{\"hello\":\"there\"}");
        });

        api.get("/api/medium", ctx -> {
            var list = app.mediumApi.query();
            ctx.json(list);
        });

        api.get("/api/pursuit", ctx -> {
            try {
                var params = new QueryParams(ctx.queryParamMap());
                var list = app.pursuitApi.query(params);
                ctx.json(list);
            } catch (api.InvalidRequest x) {
                ctx.status(422);
                ctx.json(new api.ErrorResponse(x.getMessage()));
            }
        });
        api.get("/api/pursuit/{id}", ctx -> {
            try {
                var id = Integer.parseInt(ctx.pathParam("id"));
                var pursuit = app.pursuitApi.getById(id);
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
                var updated = app.pursuitApi.update(id, payload);
                if (!updated) {
                    ctx.status(NOT_FOUND);
                }
            } catch (NumberFormatException x) {
                ctx.status(NOT_FOUND);
            }
        });

        api.post("/api/gpsfile", ctx -> {
            var file = ctx.uploadedFile("file");
            if (file == null)
                throw new UnprocessableContentResponse();
            var path = App.temp_dir + file.filename();
            FileUtil.streamToFile(file.content(), path);

            var pursuit = app.importFile(path);
            ctx.json(pursuit);
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
    }

    static void config(JavalinConfig config) {
        config.bundledPlugins
                .enableCors(cors -> cors.addRule(CorsPluginConfig.CorsRule::anyHost));
        config.jsonMapper(gsonMapper());
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
