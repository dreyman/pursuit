package util;

public class Sql {

public static String insertOne(String table, String... columns) {
    return insert(table, 1, columns);
}

public static String insert(String table, int count, String... columns) {
    assert columns != null;
    assert columns.length > 0;

    var query = new StringBuilder("INSERT INTO ").append(table).append(" (");
    var values = new StringBuilder(columns.length * 3 - 2);
    for (int i = 0; i < columns.length; i++) {
        if (i > 0) {
            query.append(", ");
            values.append(", ");
        }
        query.append(columns[i]);
        values.append('?');
    }
    query.append(") VALUES ");
    for (int i = 0; i < count; i++) {
        if (i > 0) query.append(", ");
        query.append('(').append(values).append(')');
    }
    query.append(" RETURNING id");
    return query.toString();
}

}
