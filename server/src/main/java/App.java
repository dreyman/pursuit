import pursuit.Pursuit;

import java.io.File;
import java.nio.file.Path;

public class App {
    static String STORAGE_DIR = "WIP";
    static String LIB_PATH = "../engine/zig-out/lib/libpursuit.so";

    String app_dir;
    String sqlite_db_file;
    String routes_dir;
    String temp_dir;
    String cli_path;

    public pursuit.Api pursuitApi;
    public medium.Api mediumApi;
    public Engine engine;

    public App() {
        String home = System.getenv("HOME");
        if (home == null) {
            throw new RuntimeException("HOME not found");
        }
        var app_dir_path = Path.of(home, STORAGE_DIR);

        this.app_dir = app_dir_path.toString();
        this.sqlite_db_file = app_dir_path.resolve("pursuit.db").toString();
        this.routes_dir = app_dir_path.resolve("routes").toString();
        this.temp_dir = app_dir_path.resolve("temp").toString();
        this.cli_path = app_dir_path.resolve("prst").toString();

        pursuitApi = new pursuit.Api(sqlite_db_file);
        mediumApi = new medium.Api(sqlite_db_file, pursuitApi);
        engine = new ForeignEngine(LIB_PATH, app_dir_path.toString());
    }

    public Pursuit importFile(String path) {
        try {
            var id = engine.importFile(path);
            if (id == 0) {
                throw new RuntimeException("Unexpected result");
            }
            var deleted = new File(path).delete();
            // fixme proper logging
            if (!deleted)
                System.out.printf("Failed to delete temp file: %s", path);
            return pursuitApi.getById(id);
        } catch (Engine.Err err) {
            err.printStackTrace();
            throw new RuntimeException("Unexpected result");
        }
    }

    public File getTrackFile(int pursuit_id) {
        return new File(Path.of(routes_dir, String.valueOf(pursuit_id), "track").toString());
    }
}
