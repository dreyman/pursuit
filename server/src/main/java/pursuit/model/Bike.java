package pursuit.model;

import java.time.Instant;

public class Bike {
    public class Part {
        public String id;
        public String bike;
        public String name;
        public int distance;

    }
    public String id;
    public String name;
    public int distance;
    public int time;
    public Instant created_at;
    public boolean archived;
}
