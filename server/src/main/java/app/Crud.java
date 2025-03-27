package app;

public class Crud {

//    Database db;
//    Cli cli;

    final String cliPath = "/home/ihor/code/pursuit/engine/zig-out/bin/prst";
    final String dbUrl = "/home/ihor/.pursuit/pursuit.db";


//    public Crud() {
//        this.db = new SqliteDb(dbUrl);
//        this.cli = new Cli(cliPath);
//    }
//
//    public Pursuit getPursuit(int id) throws Exception {
//        return db.getPursuit(id);
//    }
//
//    public List<Pursuit> getRoutes() throws Exception {
//        return db.getPursuits();
//    }
//
//    public List<Bike> getBikes() throws Exception {
//        return db.getBikes();
//    }
//
//    public Pursuit importFromFile(String path) throws Exception {
//        var id = cli.importFromFile(path);
//        return db.getPursuit(id);
//    }
//
//    public Bike createBike(Bike bike) throws Exception {
//        bike.distance = 0;
//        bike.time = 0;
//        bike.archived = false;
//        bike.created_at = Instant.now();
//        db.saveBike(bike);
//        return bike;
//    }
}
