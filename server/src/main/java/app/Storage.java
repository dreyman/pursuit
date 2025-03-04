package app;

import java.io.File;

public class Storage {
    final String storageDir = "/home/ihor/.wild-fields";

    File getTrack(int routeId) {
        return new File(storageDir + "/" + routeId + "/track");
    }
}
