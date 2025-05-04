import java.io.File;
import java.lang.foreign.*;
import java.nio.file.Path;

public class Playground {
    public static void main(String[] args) {
        var lib_file_path = "../engine/zig-out/lib/libpursuit.so";
        File file = new File(lib_file_path);
        System.out.println("FILE EXISTS: " + file.exists());

        var LIB_FN = "pursuit_version";
        var LIB_FN_DESCRIPTOR = FunctionDescriptor.of(ValueLayout.ADDRESS);

        String version = null;

        try (Arena arena = Arena.ofConfined()) {
            var path = Path.of(lib_file_path);
            SymbolLookup libpursuit = SymbolLookup.libraryLookup(path, arena);
            var func_ptr = libpursuit.find(LIB_FN)
                    .orElseThrow(() -> new RuntimeException("FUNC NOT FOUND"));
            var fn_handle = Linker.nativeLinker().downcallHandle(func_ptr, LIB_FN_DESCRIPTOR);

            MemorySegment result = (MemorySegment) fn_handle.invokeExact();
            result = result.reinterpret(Long.MAX_VALUE);
            version = result.getString(0);
        } catch (Throwable t) {
            t.printStackTrace();
            System.out.println("ERROR");
        }

        if (version != null) System.out.println("SUCCESS: " + version);
    }
}
