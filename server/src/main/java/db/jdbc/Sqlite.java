package db.jdbc;

import db.StrictSqlite;

import java.sql.*;

public class Sqlite implements StrictSqlite {

String db_url;

public Sqlite(String db_file_path) {
    this.db_url = "jdbc:sqlite:" + db_file_path;
}

public StrictSqlite.Transaction transaction() {
    return new db.jdbc.Transaction(db_url);
}

public void execute(String sql, Object... args) {
    try (var c = DriverManager.getConnection(db_url);
         var s = c.prepareStatement(sql)) {
        if (args != null && args.length > 0)
            db.jdbc.Transaction.setArgs(s, args);
        s.execute();
    } catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

}
