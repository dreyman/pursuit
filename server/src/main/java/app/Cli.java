package app;

import app.model.Route;
import com.google.gson.FieldNamingPolicy;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonSyntaxException;

import java.io.IOException;
import java.time.Instant;
import java.util.concurrent.TimeUnit;

public class Cli {
    final String version = "0.0.1-dev";
    String cli_path;
    Gson gson;

    public static class InvalidResult extends Exception {
    }

    public Cli(String path) {
        this.cli_path = path;
        this.gson = new GsonBuilder()
                .setFieldNamingPolicy(FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES)
                .create();
    }

    public Route importFromFile(String filePath)
            throws InterruptedException, IOException, InvalidResult {
        var pb = new ProcessBuilder(cli_path, "add", filePath);
        var process = pb.start();
        process.waitFor(1, TimeUnit.MINUTES);
        int exitStatus = process.exitValue();
        if (exitStatus == 0) {
            try (var reader = process.inputReader()) {
                var json = reader.readLine();
                try {
                    var stats = gson.fromJson(json, Route.Stats.class);
                    var route = gson.fromJson(json, Route.class);
                    route.id = stats.start();
                    route.name = Instant.ofEpochSecond(stats.start()).toString();
                    route.stats = stats;
                    return route;
                } catch (JsonSyntaxException x) {
                    throw new InvalidResult();
                }
            }
        }
        return null;
    }

}
