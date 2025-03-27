package pursuit;

import org.junit.jupiter.api.Test;

import java.lang.reflect.Field;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class ListItemTest {

    @Test
    void checkFields() {
        List<String> itemFields = Arrays.stream(ListItem.class.getFields())
                .map(Field::getName)
                .collect(Collectors.toList());
        List<String> allFields = Arrays.stream(Pursuit.class.getFields())
                .map(Field::getName)
                .collect(Collectors.toList());

        assertTrue(allFields.containsAll(itemFields));
        assertTrue(itemFields.contains("id"));
    }
}
