package core;

public interface Engine {

    String version() throws Err;

    int importFile(String path) throws Err;

    void recalcStats(int id, int min_speed, int max_time_gap) throws Err;

    String locationFlybys(float lat,
                          float lon,
                          double max_distance,
                          int time_gap) throws Err;

    class Err extends Exception {
        String message;

        public Err(String message) {
            this.message = message;
        }

        public Err(String message, Throwable t) {
            super(t);
            this.message = message;
        }

        public static Err functionNotFound(String func_name) {
            return new Err(String.format("Function '%s' not found.", func_name));
        }

        public Err(Throwable x) {
            super(x);
        }
    }
}
