import pursuit.Pursuit;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;

public class App {
    String app_dir;
    String sqlite_db_file;
    String routes_dir;
    String temp_dir;
    String cli_path;

    public pursuit.Api pursuitApi;
    public medium.Api mediumApi;
    public Engine engine;

    public App() {
        String home_env = System.getenv("HOME");
        if (home_env == null) {
            throw new RuntimeException("HOME not found");
        }
        var app_dir_path = Path.of(home_env, ".pursuit");

        this.app_dir = app_dir_path.toString();
        this.sqlite_db_file = app_dir_path.resolve("pursuit.db").toString();
        this.routes_dir = app_dir_path.resolve("routes").toString();
        this.temp_dir = app_dir_path.resolve("temp").toString();
        this.cli_path = app_dir_path.resolve("prst").toString();

        pursuitApi = new pursuit.Api(sqlite_db_file);
        mediumApi = new medium.Api(sqlite_db_file);
        engine = new Engine(cli_path);
    }

    public Pursuit importFile(String path) {
        try {
            var id = engine.importFile(path);
            if (id == -1) {
                throw new RuntimeException("Unexpected result");
            }
            new File(path).delete();
            return pursuitApi.getById(id);
        } catch (InterruptedException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        } catch (IOException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }

    File getTrackFile(int pursuit_id) {
        return new File(Path.of(routes_dir, String.valueOf(pursuit_id), "track").toString());
    }
}
