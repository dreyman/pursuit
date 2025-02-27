package fields.wild.storage;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

public class Importer {

    String cli_path = "/home/ihor/code/wild-fields/engine/zig-out/bin/wf";

    public enum Result {
        IN_PROGRESS,
        SUCCESS,
        FAILURE,
    }

    public Result importEntry(String filePath) throws InterruptedException, IOException {
//        try {
            var pb = new ProcessBuilder(cli_path, "add", filePath);
            var process = pb.start();
            process.waitFor(1, TimeUnit.MINUTES);
            int exitStatus = process.exitValue();
            return exitStatus == 0 ? Result.SUCCESS : Result.FAILURE;
//        } catch (IOException e) {
//            throw new RuntimeException(e);
//        } catch (InterruptedException e) {
//            //handle
//            throw new RuntimeException(e);
//        }
    }
}
