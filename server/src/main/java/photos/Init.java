package photos;

import java.io.File;
import java.sql.SQLException;

public class Init {
static final int min_timestamp = 90_000;

photos.Repository repository;

public static class Err extends Exception {
    public Err(String message) {
        super(message);
    }
}

public Init(photos.Repository repository) {
    this.repository = repository;
}

public void fromDirectory(String dir_path) throws Init.Err {
    var dir = new File(dir_path);
    if (!dir.isDirectory())
        throw new Err(String.format("Must be a directory: %s", dir_path));
    fromDirectory(dir);
}

public void fromDirectory(File dir) throws Init.Err {
    var extractor = new MetadataExtractor();
    if (!dir.isDirectory())
        throw new Err("Must be a directory");
    File[] files = dir.listFiles();
    System.out.println("Boutta import dir: " + dir.getName() +
            " (" + (files != null ? files.length : "null") + " files)");
    if (files == null)
        return;
    for (File file : files) {
        if (file.isDirectory()) {
            fromDirectory(file);
            continue;
        }
        var photo = new Photo();
        photo.file = file.getAbsolutePath();
        var result = extractor.readMetadata(file);
        if (result.err() == null) {
            var md = result.metadata();
            photo.metadata = result.metadata();
            if (md.timestamp() != null && md.timestamp() >= min_timestamp && md.timezone() != null) {
                photo.timestamp = md.timestamp();
            }
        } else {
            photo.metadata = Metadata.empty();
            System.err.printf(
                    "Failed to extract metadata: %s (%s)",
                    file.getName(), result.err().getClass()
            );
        }
        try {
            this.repository.insert(photo);
            System.out.print('+');
        } catch (SQLException e) {
            System.err.printf("\nFailed to insert photo: (file=%s)\n", photo.file);
            throw new RuntimeException(e);
        }
    }
}
}
