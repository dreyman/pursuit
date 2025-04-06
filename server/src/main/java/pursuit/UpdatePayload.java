package pursuit;

public class UpdatePayload {
    public String name;
    public String description;
    public Pursuit.Kind kind;
    public Integer medium_id;

    public boolean isEmpty() {
        return name == null &&
                description == null &&
                kind == null &&
                medium_id == null;
    }
}
