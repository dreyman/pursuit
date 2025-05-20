package db.jdbc;

import db.StrictSqlite;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class QueryResult implements StrictSqlite.QueryResult {

public Statement stmt;
ResultSet rs;
boolean has_next;
int idx = 0;

public QueryResult(Statement stmt, ResultSet rs) {
    this.stmt = stmt;
    this.rs = rs;
    try {
        this.has_next = rs.next();
    } catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

public boolean hasNext() throws StrictSqlite.Err {
    return has_next;
}

public StrictSqlite.Row next() throws StrictSqlite.Err {
    try {
        if (!hasNext())
            return null;
        if (idx > 0)
            this.has_next = this.rs.next();
        idx++;
        return new db.jdbc.Row(this.rs);
    } catch (SQLException x) {
        throw new StrictSqlite.Err(x.getMessage(), x.getErrorCode());
    }
}

}
