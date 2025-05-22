import com.google.gson.Gson;
import core.Location;
import engine.Engine;
import engine.ForeignEngine;
import landmarks.Service;
import photos.Photo;
import pursuit.Pursuit;

import java.io.File;
import java.nio.file.Path;
import java.sql.SQLException;
import java.time.ZoneId;

public class App {
static final String libpursuit_version = "0.0.1-wip";

String sqlite_db_file;
String routes_dir;
String temp_dir;

public pursuit.Api pursuit_api;
public medium.Api medium_api;
public Service landmarks;
public landmarks.Rest landmarks_api;
public stats.Api stats_api;
public location.Api location_api;
public photos.Api photos_api;
public tag.Repository tag_repo;
public Engine engine;

public Gson gson;

public App(String storage_dir, String lib_file_path) {
    var app_dir = Path.of(storage_dir);

    this.sqlite_db_file = app_dir.resolve("pursuit.db").toString();
    this.routes_dir = app_dir.resolve("routes").toString();
    this.temp_dir = app_dir.resolve("temp").toString();

    engine = new ForeignEngine(lib_file_path, storage_dir);
    pursuit_api = new pursuit.Api(sqlite_db_file);
    medium_api = new medium.Api(sqlite_db_file, pursuit_api);
    landmarks = new landmarks.Service(sqlite_db_file);
    landmarks_api = new landmarks.Rest(landmarks);
    stats_api = new stats.Api(engine, pursuit_api);
    location_api = new location.Api(engine, pursuit_api);
    photos_api = new photos.Api(sqlite_db_file);
    tag_repo = new tag.Repository(sqlite_db_file);

    gson = new Gson();
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
            app.landmarks.setup();
        } catch (Exception x) {
            var err = "Failed to setup landmarks db: " + x.getMessage();
            System.err.println(err);
            throw new RuntimeException(err);
        }
        try {
            app.photos_api.setup();
        } catch (Exception x) {
            var err = "Failed to setup landmarks db: " + x.getMessage();
            System.err.println(err);
            throw new RuntimeException(err);
        }
    }

//    try {
//        var photos_dir = "";
//        var tz = ZoneId.of("");
//        app.photos_api.repo.setup();
//        app.photos_api.importFromDirectory(photos_dir);
//        adjustTimestamp(app, tz);
//        findDerivedPhotosLocation(app);
//    } catch (SQLException e) {
//        throw new RuntimeException(e);
//    }
//    if (true) throw new RuntimeException("======================= ABORTED =======================");

    return app;
}

static void adjustTimestamp(App app, ZoneId tz) throws SQLException {
    var photos = app.photos_api.repo.listWithoutMetadataTimezone();
    for (Photo photo : photos) {
        Integer timestamp = photo.metadata.timestamp();
        int new_timestamp = util.Time.offsetTimestampForTimezone(timestamp, tz);
        app.photos_api.repo.updateTimestamp(photo.id, new_timestamp);
        System.out.print('z');
    }
}

static void findDerivedPhotosLocation(App app) throws SQLException {
    var photos = app.photos_api.repo.listAll();
    var count = 0;
    for (Photo photo : photos) {
        if (photo.derived_location != null || photo.timestamp == null)
            continue;
        try {
            var location = app.engine.locationByTimestamp(photo.timestamp);
            if (location == null || location.lat == 0) {
//                System.out.print("Location not found for: " + photo.file);
                System.out.print('|');
                continue;
            }
//            System.out.println("Photo: " + photo.file);
//            System.out.println("Location: " + location.lat + ", " + location.lon);
            System.out.print('.');
            photo.derived_location = new Location(location.lat, location.lon);
            try {
                app.photos_api.repo.updateDerivedLocation(photo);
                count++;
            } catch (Exception x) {
                System.err.println("Err " + x.getClass());
                System.err.printf(
                        "Failed to update derived location id=%d (%s)\n",
                        photo.id, photo.file
                );
            }
        } catch (Engine.Err err) {
            System.err.println("Engine err: " + err.getMessage());
            System.err.printf("Photo id=%d (%s))\n", photo.id, photo.file);
        }
    }
    System.out.println("Updated derived location: " + count);
}

public Pursuit importFile(String path) {
    try {
        var id = engine.importFile(path);
        if (id == 0) {
            throw new RuntimeException("Unexpected result");
        }
        return pursuit_api.getById(id);
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
