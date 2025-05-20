package db;

public interface StrictSqlite {

Transaction transaction();

void execute(String sql, Object... args);

interface Transaction extends AutoCloseable {
    int update(String sql, Object... args);

    QueryResult query(String sql, Object... args);

    void commit();

    void rollback();

    void close() throws Err;
}

interface QueryResult {

    boolean hasNext() throws Err;

    Row next() throws Err;
}

interface Row {
    // INT / INTEGER
    int getInt(String column);

    long getLong(String column);

    // TEXT
    String getString(String column);

    // REAL
    double getDouble(String column);

    float getFloat(String column);
}

class Err extends RuntimeException {
    public Integer err_code;

    public Err(String message, Integer err_code) {
        super(message);
        this.err_code = err_code;
    }

    boolean constraintViolation() {
        return err_code != null && err_code == 19;
    }

    boolean misuse() {
        return err_code != null && err_code == 21;
    }
}
}
