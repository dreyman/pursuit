import core.Engine;
import core.ForeignEngine;
import pursuit.Pursuit;
import stats.Stats;

import java.io.File;
import java.nio.file.Path;

public class App {

    Config config;
    String sqlite_db_file;
    String routes_dir;
    String temp_dir;

    public pursuit.Api pursuitApi;
    public medium.Api mediumApi;
    public landmarks.Api landmarksApi;
    public landmarks.Rest landmarksRestApi;
    public location.Api locationApi;
    public Engine engine;

    public App(Config config) {
        this.config = config;
        var app_dir = Path.of(config.storage_dir);

        this.sqlite_db_file = app_dir.resolve("pursuit.db").toString();
        this.routes_dir = app_dir.resolve("routes").toString();
        this.temp_dir = app_dir.resolve("temp").toString();

        pursuitApi = new pursuit.Api(sqlite_db_file);
        mediumApi = new medium.Api(sqlite_db_file, pursuitApi);
        landmarksApi = new landmarks.Api(sqlite_db_file);
        landmarksRestApi = new landmarks.Rest(landmarksApi);
        engine = new ForeignEngine(config.libpursuit_path, config.storage_dir);
        locationApi = new location.Api(engine, pursuitApi);
    }

    public Pursuit importFile(String path) {
        try {
            var id = engine.importFile(path);
            if (id == 0) {
                throw new RuntimeException("Unexpected result");
            }
            return pursuitApi.getById(id);
        } catch (Engine.Err err) {
            err.printStackTrace();
            throw new RuntimeException("Unexpected result");
        }
    }

    public Stats recalcStats(int id, int min_speed, int max_time_gap) {
        try {
            engine.recalcStats(id, min_speed, max_time_gap);
            // fixme just retrieve stats (or even only recalculated fields)
            var pursuit = pursuitApi.getById(id);
            return pursuit.stats;
        } catch (Engine.Err e) {
            e.printStackTrace();
            throw new api.InternalError();
        }
    }

    public File getTrackFile(int pursuit_id) {
        Path path = Path.of(routes_dir, String.valueOf(pursuit_id), "track");
        return new File(path.toString());
    }
}
