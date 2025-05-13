package util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class SqlTest {

@Test
public void insert() {
    var table = "some_table";
    String sql = Sql.insert(table, 3, "name", "age", "created_at");
    var expected =
            "INSERT INTO " + table +
            " (name, age, created_at) VALUES " +
            "(?, ?, ?) (?, ?, ?) (?, ?, ?)";
    assertEquals(expected, sql);
}

@Test
public void insertOne() {
    var table = "some_table";
    String sql = Sql.insertOne(table, "name", "age", "created_at");
    var expected =
            "INSERT INTO " + table +
                    " (name, age, created_at) VALUES " +
                    "(?, ?, ?)";
    assertEquals(expected, sql);
}
}
