public interface Engine {

    class Err extends Exception {
        public Err() {
        }

        public Err(Throwable x) {
            super(x);
        }
    }

    record RecalcStatsOptions(byte min_speed, byte max_time_gap) {
    }

    String version() throws Err;

    int importFile(String path) throws Err;

    void recalcStats(int id, RecalcStatsOptions options) throws Err;
}
