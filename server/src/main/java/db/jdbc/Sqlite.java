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

//public int update(String sql, Object... args) {
//    try (var c = DriverManager.getConnection(db_url);
//         var s = c.prepareStatement(sql)) {
//        if (args != null)
//            setArgs(s, args);
//        return s.executeUpdate();
//    } catch (SQLException x) {
//        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
//    }
//}
//
//public db.jdbc.QueryResult query(String sql, Object... args) {
//    Connection c = null;
//    PreparedStatement s = null;
//    try {
//        c = DriverManager.getConnection(db_url);
//        s = c.prepareStatement(sql);
//        if (args != null)
//            setArgs(s, args);
//        var rs = s.executeQuery();
//        return new db.jdbc.QueryResult(s, rs);
//    } catch (SQLException x) {
//        if (s != null) try {s.close();} catch (SQLException close_err) {
//            throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
//        }
//        if (c != null) try {c.close();} catch (SQLException close_err) {
//            throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
//        }
//        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
//    }
//}

public void execute(String sql, Object... args) {
    try (var c = DriverManager.getConnection(db_url);
         var s = c.prepareStatement(sql)) {
        if (args != null && args.length > 0)
            setArgs(s, args);
        s.execute();
    } catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

void setArgs(PreparedStatement s, Object... args) throws SQLException {
    var idx = 1;
    for (Object arg : args)
        setArg(s, idx++, arg);
}

void setArg(PreparedStatement s, int idx, Object arg) throws SQLException {
    if (arg == null) {
        s.setNull(idx, java.sql.Types.NULL);
        return;
    }
    switch (arg) {
        case Integer val -> s.setInt(idx, val);
        case Long val -> s.setLong(idx, val);
        case String val -> s.setString(idx, val);
        case Float val -> s.setFloat(idx, val);
        case Double val -> s.setDouble(idx, val);
        default -> throw new IllegalArgumentException(
                "Unsupported arg type: " + arg.getClass().getName()
        );
    }
}

}
