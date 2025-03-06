package pursuit;

import pursuit.database.SqliteDb;
import pursuit.model.Bike;
import pursuit.model.Route;

import java.time.Instant;
import java.util.List;

public class Crud {

    Database db;
    Cli cli;

    final String cliPath = "/home/ihor/code/pursuit/engine/zig-out/bin/wf";
    final String dbUrl = "/home/ihor/.wild-fields/wf.db";


    public Crud() {
        this.db = new SqliteDb(dbUrl);
        this.cli = new Cli(cliPath);
    }

    public Route getRoute(int id) throws Exception {
        return db.getRoute(id);
    }

    public List<Route> getRoutes() throws Exception {
        return db.getRoutes();
    }

    public List<Bike> getBikes() throws Exception {
        return db.getBikes();
    }

    public Route importFromFile(String path) throws Exception {
        var route = cli.importFromFile(path);
        if (route == null) return null;
        route.type = Route.Type.CYCLING; // FIXME set real type here
        db.saveRoute(route);
        return route;
    }

    public Bike createBike(Bike bike) throws Exception {
        bike.id = randomString();
        bike.distance = 0;
        bike.time = 0;
        bike.archived = false;
        bike.created_at = Instant.now();
        db.saveBike(bike);
        return bike;
    }

    String randomString() {
        return Long.toString(System.currentTimeMillis());
    }
}
