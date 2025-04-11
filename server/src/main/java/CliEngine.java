import java.io.IOException;
import java.util.concurrent.TimeUnit;

public class Engine {
    public String cli_path;

    public Engine(String cli_path) {
        this.cli_path = cli_path;
    }

    public int importFile(String path)
            throws InterruptedException, IOException {
        var pb = new ProcessBuilder(cli_path, "add", path);
        var process = pb.start();
        process.waitFor(1, TimeUnit.MINUTES);
        int exitStatus = process.exitValue();
        if (exitStatus == 0) {
            try (var reader = process.inputReader()) {
                var result = reader.readLine();
                var expected = "done. id=";
                if (result.startsWith("done. id=")) {
                    var id = Integer.parseInt(result, expected.length(), result.length(), 10);
                    return id;
                }
            }
        }
        return -1;
    }
}
