package app;

import java.io.File;

public class Storage {
    final String storageDir = "/home/ihor/.pursuit";

    File getTrackFile(int routeId) {
        return new File(storageDir + "/" + routeId + "/track");
    }
}
