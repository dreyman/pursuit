package core;

import java.util.concurrent.TimeUnit;

public class CliEngine  {
    public String cli_path;

    public CliEngine(String cli_path) {
        this.cli_path = cli_path;
    }

    public String version() throws Engine.Err {
        throw new UnsupportedOperationException();
    }

    public int importFile(String path) throws Engine.Err {
        var pb = new ProcessBuilder(cli_path, "add", path);
        try {
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
        } catch (Exception x) {
            throw new Engine.Err(x);
        }
    }
}
