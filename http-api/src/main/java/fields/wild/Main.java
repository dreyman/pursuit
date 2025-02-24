package fields.wild;

import io.javalin.Javalin;
import io.javalin.http.ContentType;

import java.io.File;
import java.io.FileInputStream;

import static io.javalin.http.HttpStatus.NOT_FOUND;

public class Main {
    public static void main(String[] args) {
        var app = Javalin.create(config -> {
            config.bundledPlugins.enableCors(cors -> {
                cors.addRule(it -> {
                    it.anyHost();
                });
            });
                })
                .get("/{id}/latlon", ctx -> {
                    try {
                        var id = Integer.parseInt(ctx.pathParam("id"));
                        var latlon = new File("/home/ihor/.wild-fields/" + id + "/latlon");
                        ctx.contentType(ContentType.APPLICATION_OCTET_STREAM);
                        ctx.result(new FileInputStream(latlon));
                    } catch (NumberFormatException x) {
                        ctx.status(NOT_FOUND);
                    }
                })
                .get("/hello", ctx -> {
                    ctx.result("{\"hello\": \"there\"}");
                })
                .start(7070);
    }
}
