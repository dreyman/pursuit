package fields.wild;

import fields.wild.storage.Importer;
import fields.wild.storage.Storage;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.*;

public class Service {

    Storage storage;
    ExecutorService executorService;
    Importer importer;

    private Map<Integer, Importer.Result> imports;
    private Random rand;

    public Service(Storage storage) {
        this.storage = storage;
        this.executorService = Executors.newVirtualThreadPerTaskExecutor();
        this.importer = new Importer();
        this.imports = new ConcurrentHashMap<>();
        this.rand = new Random();
    }

    public int importEntry(String path) {
        final var importId = rand.nextInt();
        imports.put(importId, Importer.Result.IN_PROGRESS);
        executorService.submit(() -> {
            try {
                var result = importer.importEntry(path);
                imports.put(importId, result);
                return Importer.Result.SUCCESS;
            } catch (InterruptedException | IOException x) {
                imports.put(importId, Importer.Result.FAILURE);
                return Importer.Result.FAILURE;
            }
        });
        return importId;

        // run cmd
        // on success:
        //      - write to sqlite
        //      - clean up tmp
        // on failure:
        //      - clean up tmp etc.
    }

}
