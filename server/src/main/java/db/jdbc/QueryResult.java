package db.jdbc;

import db.StrictSqlite;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class QueryResult implements StrictSqlite.QueryResult {

public Statement stmt;
ResultSet rs;

public QueryResult(Statement stmt, ResultSet rs) {
    this.stmt = stmt;
    this.rs = rs;
}

public boolean next() {
    try {return this.rs.next();} catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

public int getInt(String column) {
    try {return rs.getInt(column);} catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

public long getLong(String column) {
    try {return rs.getLong(column);} catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

public String getString(String column) {
    try {return rs.getString(column);} catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

public double getDouble(String column) {
    try {return rs.getDouble(column);} catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

public float getFloat(String column) {
    try {return rs.getFloat(column);} catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

}
