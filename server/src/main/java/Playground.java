import java.nio.file.Path;

public class Playground {
    static String LIB = "/home/ihor/code/pursuit/engine/zig-out/lib/libpursuit.so";
    static String STORAGE = "/home/ihor/WIP";

    public static void main(String[] args) throws Engine.Err {
        var file = "/home/ihor/501/230719192644.fit";
        var engine = new ForeignEngine("../engine/zig-out/lib/libpursuit.so", STORAGE);
        System.out.println(engine.version());
    }

}
