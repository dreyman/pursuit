package pursuit.database;

public class Queries {

    public static final String create_routes_table = """
                CREATE TABLE IF NOT EXISTS routes (
                    id INTEGER PRIMARY KEY,
                    name TEXT NOT NULL,
                    type TEXT NOT NULL,
                    bike TEXT,
                    start INTEGER NOT NULL,
                    end INTEGER NOT NULL,
                    distance INTEGER NOT NULL,
                    total_time INTEGER NOT NULL,
                    moving_time INTEGER NOT NULL,
                    stops_count INTEGER NOT NULL,
                    stops_duration INTEGER NOT NULL,
                    untracked_distance INTEGER NOT NULL,
                    min_lat REAL NOT NULL,
                    max_lat REAL NOT NULL,
                    min_lon REAL NOT NULL,
                    max_lon REAL NOT NULL,
                    FOREIGN KEY(bike) REFERENCES bikes(id)
                );
            """;

    public static final String create_bikes_table = """
                CREATE TABLE IF NOT EXISTS bikes (
                    id text primary key not null,
                    name text not null,
                    distance integer not null,
                    time integer not null,
                    created_at integer not null,
                    archived integer not null
                );
            """;

    public static final String create_bike_parts_table = """
                CREATE TABLE IF NOT EXISTS bike_parts (
                    id text primary key not null,
                    bike text,
                    name text not null,
                    distance integer not null,
                    archived integer not null,
                    FOREIGN KEY(bike) REFERENCES bikes(id)
                );
            """;

    private Queries() {
    }
}
