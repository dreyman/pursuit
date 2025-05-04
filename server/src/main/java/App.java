import core.Engine;
import core.ForeignEngine;
import pursuit.Pursuit;

import java.io.File;
import java.nio.file.Path;

public class App {
    static final String libpursuit_version = "0.0.1-wip";

    String sqlite_db_file;
    String routes_dir;
    String temp_dir;

    public pursuit.Api pursuitApi;
    public medium.Api mediumApi;
    public landmarks.Api landmarksApi;
    public landmarks.Rest landmarksRestApi;
    public stats.Api statsApi;
    public location.Api locationApi;
    public Engine engine;

    public App(String storage_dir, String lib_file_path) {
        var app_dir = Path.of(storage_dir);

        this.sqlite_db_file = app_dir.resolve("pursuit.db").toString();
        this.routes_dir = app_dir.resolve("routes").toString();
        this.temp_dir = app_dir.resolve("temp").toString();

        engine = new ForeignEngine(lib_file_path, storage_dir);
        pursuitApi = new pursuit.Api(sqlite_db_file);
        mediumApi = new medium.Api(sqlite_db_file, pursuitApi);
        landmarksApi = new landmarks.Api(sqlite_db_file);
        landmarksRestApi = new landmarks.Rest(landmarksApi);
        statsApi = new stats.Api(engine, pursuitApi);
        locationApi = new location.Api(engine, pursuitApi);
    }

    public static App initFromArgs(String[] args) {
        if (args.length < 1 || args[0] == null)
            throw new RuntimeException("expected args: <storage_dir_path> [<lib_file_path>]");
        var storage_dir_path = args[0];
        var lib_path = args.length > 1 ? args[1] : "../engine/zig-out/lib/libpursuit.so";
        var storage_dir = new File(storage_dir_path);
        if (!storage_dir.isDirectory()) {
            throw new RuntimeException("<storage_dir_path> must be a directory");
        }
        App app = new App(storage_dir_path, lib_path);
        try {
            String version = app.engine.version();
            if (!version.equals(libpursuit_version)) {
                var err = String.format("incompatible libpursuit version, expected: '%s', but got '%s'.", libpursuit_version, version);
                throw new RuntimeException(err);
            }
        } catch (Engine.Err e) {
            throw new RuntimeException("failed to get libpursuit version from: " + lib_path);
        }

        File db_file = storage_dir.toPath().resolve("pursuit.db").toFile();
        if (!db_file.exists()) {
            try {
                app.engine.install();
            } catch (Engine.Err err) {
                System.err.println(err.getMessage());
                throw new RuntimeException("failed to init app in storage path: " + storage_dir_path);
            }
            try {
                app.landmarksApi.setup();
            } catch (Exception x) {
                var err = "Failed to setup landmarks db: " + x.getMessage();
                System.err.println(err);
                throw new RuntimeException(err);
            }
        }

        return app;
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

    public File getTrackFile(int pursuit_id) {
        Path path = Path.of(routes_dir, String.valueOf(pursuit_id), "track");
        return new File(path.toString());
    }
}
