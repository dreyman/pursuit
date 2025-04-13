import java.lang.foreign.*;
import java.nio.file.Path;

import static java.lang.foreign.FunctionDescriptor.of;
import static java.lang.foreign.ValueLayout.*;

public class ForeignEngine implements Engine {

    record Func(String name, FunctionDescriptor descriptor) {
    }

    static final Func import_file_func = new Func("pursuit_import_file", of(JAVA_INT, ADDRESS, ADDRESS));
    static final Func version_func = new Func("pursuit_version", of(ADDRESS));
    static final Func recalc_stats_func = new Func("pursuit_recalc_stats",
            of(JAVA_BYTE, ADDRESS, JAVA_INT, JAVA_BYTE, JAVA_BYTE));

    public String lib_path;
    public String storage_path;

    public ForeignEngine(String lib_path, String storage_path) {
        this.lib_path = lib_path;
        this.storage_path = storage_path;
    }

    public int importFile(String gpsfile) throws Engine.Err {
        try (Arena arena = Arena.ofConfined()) {
            var path = Path.of(lib_path);
            SymbolLookup libpursuit = SymbolLookup.libraryLookup(path, arena);
            var func_ptr = libpursuit.find(import_file_func.name).orElseThrow(Engine.Err::new);
            var func = Linker.nativeLinker().downcallHandle(func_ptr, import_file_func.descriptor);

            var file_path = arena.allocateFrom(gpsfile);
            var storage_path = arena.allocateFrom(this.storage_path);
            int id = (int) func.invokeExact(file_path, storage_path);
            return id;
        } catch (Throwable t) {
            throw new Engine.Err(t);
        }
    }

    public void recalcStats(int id, RecalcStatsOptions options) throws Err {
        try (Arena arena = Arena.ofConfined()) {
            var path = Path.of(lib_path);
            SymbolLookup libpursuit = SymbolLookup.libraryLookup(path, arena);
            var func_ptr = libpursuit.find(recalc_stats_func.name).orElseThrow(Engine.Err::new);
            var func = Linker.nativeLinker().downcallHandle(func_ptr, recalc_stats_func.descriptor);

            var storage_path = arena.allocateFrom(this.storage_path);
            byte result = (byte) func.invokeExact(
                    storage_path,
                    id,
                    options.min_speed(),
                    options.max_time_gap()
            );
            if (result != 0)
                throw new Engine.Err();
        } catch (Throwable t) {
            throw new Engine.Err(t);
        }
    }

    public String version() throws Engine.Err {
        try (Arena arena = Arena.ofConfined()) {
            var path = Path.of(lib_path);
            SymbolLookup libpursuit = SymbolLookup.libraryLookup(path, arena);
            var func_ptr = libpursuit.find(version_func.name).orElseThrow(Engine.Err::new);
            var func = Linker.nativeLinker().downcallHandle(func_ptr, version_func.descriptor);

            MemorySegment result = (MemorySegment) func.invokeExact();
            result = result.reinterpret(Long.MAX_VALUE);
            return result.getString(0);
        } catch (Throwable t) {
            throw new Engine.Err();
        }
    }
}
