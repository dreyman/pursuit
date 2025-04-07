package medium;

public class CreatePayload {
    public String name;
    public Medium.Kind kind;

    public String validate() {
        if (name == null)
            return "Missing required field: name.";
        if (name.length() < 2 || name.length() > 100)
            return "Invalid 'name' value";
        if (kind == null)
            return "Invalid 'kind' value";
        return null;
    }
}
