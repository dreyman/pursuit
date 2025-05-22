package db.jdbc;

import db.StrictSqlite;

import java.sql.*;

public class Transaction implements StrictSqlite.Transaction, AutoCloseable {

String db_url;
Connection conn;
Statement stmt;

public Transaction(String db_url) {
    this.db_url = db_url;
}

public int update(String sql, Object... args) {
    var c = getConnection();
    try (var s = c.prepareStatement(sql)) {
        if (args != null)
            setArgs(s, args);
        return s.executeUpdate();
    } catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

public StrictSqlite.QueryResult query(String sql, Object... args) {
    var c = getConnection();
    try {
        if (this.stmt != null)
            this.stmt.close();
        var s = c.prepareStatement(sql);
        if (args != null)
            setArgs(s, args);
        var rs = s.executeQuery();
        this.stmt = s;
        return new db.jdbc.QueryResult(s, rs);
    } catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

public void commit() {
    try {
        if (this.stmt != null)
            this.stmt.close();
        this.conn.commit();
        close();
    } catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

public void rollback() {
    try {
        this.conn.rollback();
        close();
    } catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

public void close() {
    try {
        this.conn.close();
    } catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

Connection getConnection() {
    if (conn != null)
        return conn;
    try {
        this.conn = DriverManager.getConnection(db_url);
        this.conn.setAutoCommit(false);
        return this.conn;
    } catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

static void setArgs(PreparedStatement s, Object... args) throws SQLException {
    var idx = 1;
    for (Object arg : args)
        setArg(s, idx++, arg);
}

static void setArg(PreparedStatement s, int idx, Object arg) throws SQLException {
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
