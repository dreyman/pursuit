package core;

import java.lang.foreign.*;
import java.nio.file.Path;
import java.util.List;

import static java.lang.foreign.FunctionDescriptor.of;
import static java.lang.foreign.FunctionDescriptor.ofVoid;
import static java.lang.foreign.ValueLayout.*;

public class ForeignEngine implements Engine {

    record Func(String name, FunctionDescriptor descriptor) {
    }

    static final Func import_file_fn = new Func("pursuit_import_file", of(JAVA_INT, ADDRESS, ADDRESS));
    static final Func version_fn = new Func("pursuit_version", of(ADDRESS));
    static final Func recalc_stats_fn = new Func("pursuit_recalc_stats",
            of(JAVA_INT, ADDRESS, JAVA_INT, JAVA_INT, JAVA_INT));
    static final Func closest_points_fn = new Func("pursuit_closest_points",
            of(ADDRESS, ADDRESS, JAVA_FLOAT, JAVA_FLOAT, JAVA_DOUBLE, JAVA_INT));
    static final Func free_str_fn = new Func("pursuit_free_str",
            ofVoid(ADDRESS));

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
            var func_ptr = libpursuit.find(import_file_fn.name)
                    .orElseThrow(() -> Engine.Err.functionNotFound(import_file_fn.name));
            var func = Linker.nativeLinker().downcallHandle(func_ptr, import_file_fn.descriptor);

            var file_path = arena.allocateFrom(gpsfile);
            var storage_path = arena.allocateFrom(this.storage_path);
            int id = (int) func.invokeExact(file_path, storage_path);
            return id;
        } catch (Throwable t) {
            throw new Engine.Err(t);
        }
    }

    public void recalcStats(int id, int min_speed, int max_time_gap) throws Err {
        try (Arena arena = Arena.ofConfined()) {
            var path = Path.of(lib_path);
            SymbolLookup libpursuit = SymbolLookup.libraryLookup(path, arena);
            var func_ptr = libpursuit.find(recalc_stats_fn.name)
                    .orElseThrow(() -> Engine.Err.functionNotFound(recalc_stats_fn.name));
            var func = Linker.nativeLinker().downcallHandle(func_ptr, recalc_stats_fn.descriptor);

            var storage_path = arena.allocateFrom(this.storage_path);
            int result = (int) func.invokeExact(
                    storage_path,
                    id,
                    min_speed,
                    max_time_gap
            );
            if (result != 0)
                throw new Engine.Err("Unexpected result: " + result);
        } catch (Throwable t) {
            throw new Engine.Err(t);
        }
    }

    public String locationVisits(float lat,
                                 float lon,
                                 double max_distance,
                                 int time_gap) throws Err {
        try (Arena arena = Arena.ofConfined()) {
            var path = Path.of(lib_path);
            SymbolLookup libpursuit = SymbolLookup.libraryLookup(path, arena);
            var func_ptr = libpursuit.find(closest_points_fn.name)
                    .orElseThrow(() -> Engine.Err.functionNotFound(closest_points_fn.name));
            var func = Linker.nativeLinker().downcallHandle(func_ptr, closest_points_fn.descriptor);

            var storage_path = arena.allocateFrom(this.storage_path);
            MemorySegment mem = (MemorySegment) func.invokeExact(
                    storage_path,
                    lat, lon, max_distance, time_gap
            );
            mem = mem.reinterpret(Long.MAX_VALUE);
            var json = mem.getString(0);
            // free
            var free_ptr = libpursuit.find(free_str_fn.name)
                    .orElseThrow(() -> Engine.Err.functionNotFound(free_str_fn.name));
            var free_fn = Linker.nativeLinker().downcallHandle(free_ptr, free_str_fn.descriptor);
            free_fn.invokeExact(mem);

            return json;
        } catch (Throwable t) {
            throw new Engine.Err(t);
        }
    }

    public String version() throws Engine.Err {
        try (Arena arena = Arena.ofConfined()) {
            var path = Path.of(lib_path);
            SymbolLookup libpursuit = SymbolLookup.libraryLookup(path, arena);
            var func_ptr = libpursuit.find(version_fn.name)
                    .orElseThrow(() -> Engine.Err.functionNotFound(version_fn.name));
            var func = Linker.nativeLinker().downcallHandle(func_ptr, version_fn.descriptor);

            MemorySegment result = (MemorySegment) func.invokeExact();
            result = result.reinterpret(Long.MAX_VALUE);
            return result.getString(0);
        } catch (Throwable t) {
            throw new Engine.Err("Unexpected error", t);
        }
    }
}
