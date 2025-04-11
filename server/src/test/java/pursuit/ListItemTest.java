package pursuit;

import org.junit.jupiter.api.Test;

import java.lang.reflect.Field;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class ListItemTest {

    @Test
    void checkFields() {
        Field[] itemFields = ListItem.class.getFields();
        List<String> itemFieldsNames = Arrays.stream(itemFields)
                .map(Field::getName)
                .toList();

        Field[] allFields = Pursuit.class.getFields();
        List<String> allFieldsNames = Arrays.stream(allFields)
                .map(Field::getName)
                .toList();

        for (Field field : itemFields) {
            var idx = allFieldsNames.indexOf(field.getName());
            assertTrue(idx >= 0);
            assertEquals(field.getType(), allFields[idx].getType());
        }
        assertTrue(itemFieldsNames.contains("id"));
    }
}
