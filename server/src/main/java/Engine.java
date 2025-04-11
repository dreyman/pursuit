public interface Engine {

    class Err extends Exception {
        public Err() {}
        public Err(Throwable x) {
            super(x);
        }
    }

    String version() throws Err;

    int importFile(String path) throws Err;
}
