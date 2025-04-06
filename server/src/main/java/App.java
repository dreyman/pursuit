import pursuit.Pursuit;

import java.io.File;
import java.io.IOException;

public class App {
    public static final String sqlite_db_file = "/home/ihor/.pursuit/pursuit.db";
    public static final String storage_dir = "/home/ihor/.pursuit/";
    public static final String routes_dir = storage_dir + "routes/";
    public static final String temp_dir = storage_dir + "temp/";
    public static final String cli_path = "/home/ihor/code/pursuit/engine/zig-out/bin/prst";

    public pursuit.Api pursuitApi;
    public medium.Api mediumApi;
    public Engine engine;

    public App() {
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
        return new File(routes_dir + "/" + pursuit_id + "/track");
    }
}
