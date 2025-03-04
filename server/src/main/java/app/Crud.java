package app;

import app.model.Route;

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

    public Route importFromFile(String path) throws Exception {
//        try {
        var route = cli.importFromFile(path);
        if (route == null) return null;
//            try {
        db.saveRoute(route);
        return route;
//            } catch (Exception e) {
//                e.printStackTrace();
//                return null;
//            }
//        } catch (InterruptedException | IOException | Cli.InvalidResult x) {
//            return null;
//        }
    }

}
