package pursuit;

import java.io.File;

public class Storage {
    final String storageDir = "/home/ihor/.wild-fields";

    File getTrackFile(int routeId) {
        return new File(storageDir + "/" + routeId + "/track");
    }
}
