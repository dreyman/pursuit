package core;

import java.lang.foreign.*;
import java.lang.invoke.MethodHandle;
import java.nio.file.Path;

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
    static final Func location_flybys_fn = new Func("pursuit_location_flybys",
            of(ADDRESS, ADDRESS, JAVA_FLOAT, JAVA_FLOAT, JAVA_DOUBLE, JAVA_INT));
    static final Func free_str_fn = new Func("pursuit_free_str", ofVoid(ADDRESS));
    static final Func init_fn = new Func("pursuit_init", of(JAVA_INT, ADDRESS));

    public String lib_path;
    public String storage_path;

    public ForeignEngine(String lib_path, String storage_path) {
        this.lib_path = lib_path;
        this.storage_path = storage_path;
    }

    public int importFile(String gpsfile) throws Engine.Err {
        try (Arena arena = Arena.ofConfined()) {
            var import_file_fn_handle = getLibMethodHandle(import_file_fn, arena);
            var file_path = arena.allocateFrom(gpsfile);
            var storage_path = arena.allocateFrom(this.storage_path);
            int id = (int) import_file_fn_handle.invokeExact(file_path, storage_path);
            return id;
        } catch (Throwable t) {
            throw new Engine.Err(t);
        }
    }

    public void recalcStats(int id, int min_speed, int max_time_gap) throws Err {
        try (Arena arena = Arena.ofConfined()) {
            var recalc_fn_handle = getLibMethodHandle(recalc_stats_fn, arena);
            var storage_path = arena.allocateFrom(this.storage_path);
            int result = (int) recalc_fn_handle.invokeExact(
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

    public String locationFlybys(float lat,
                                 float lon,
                                 double max_distance,
                                 int time_gap) throws Err {
        try (Arena arena = Arena.ofConfined()) {
            var methodAndLookup = getLookupAndMethodHandle(location_flybys_fn, arena);
            var flybys_fn = methodAndLookup.methodHandle;
            var libpursuit = methodAndLookup.symbolLookup;

            var storage_path = arena.allocateFrom(this.storage_path);
            var mem = (MemorySegment) flybys_fn.invokeExact(
                    storage_path,
                    lat, lon, max_distance, time_gap
            );
            mem = mem.reinterpret(Long.MAX_VALUE);
            var json = mem.getString(0);

            var free_fn = getLibMethodHandle(free_str_fn, libpursuit);
            free_fn.invokeExact(mem);

            return json;
        } catch (Throwable t) {
            throw new Engine.Err(t);
        }
    }

    public void install() throws Engine.Err {
        try (Arena arena = Arena.ofConfined()) {
            var init_fn_handle = getLibMethodHandle(init_fn, arena);
            MemorySegment storage_dir_arg = arena.allocateFrom(this.storage_path);
            var result = (int) init_fn_handle.invokeExact(storage_dir_arg);
            if (result != 0) {
                throw new Engine.Err("Unexpected result: " + result);
            }
        } catch (Throwable t) {
            throw new Engine.Err("Unexpected error", t);
        }
    }

    public String version() throws Engine.Err {
        try (Arena arena = Arena.ofConfined()) {
            var version = getLookupAndMethodHandle(version_fn, arena);
            MemorySegment result = (MemorySegment) version.methodHandle.invokeExact();
            result = result.reinterpret(Long.MAX_VALUE);
            return result.getString(0);
        } catch (Engine.Err err) {
            err.printStackTrace();
            throw err;
        } catch (Throwable t) {
            t.printStackTrace();
            throw new Engine.Err("Unexpected error", t);
        }
    }

    record MethodAndLookup(MethodHandle methodHandle, SymbolLookup symbolLookup){}

    MethodAndLookup getLookupAndMethodHandle(Func func, Arena arena) throws Engine.Err {
        var path = Path.of(lib_path);
        SymbolLookup libpursuit = SymbolLookup.libraryLookup(path, arena);
        var func_ptr = libpursuit.find(func.name)
                .orElseThrow(() -> Engine.Err.functionNotFound(func.name));
        return new MethodAndLookup(
                Linker.nativeLinker().downcallHandle(func_ptr, func.descriptor),
                libpursuit
        );
    }

    MethodHandle getLibMethodHandle(Func func, Arena arena) throws Engine.Err {
        return getLookupAndMethodHandle(func, arena).methodHandle;
    }

    MethodHandle getLibMethodHandle(Func func, SymbolLookup symbolLookup)
            throws Engine.Err{
        var func_ptr = symbolLookup.find(func.name)
                .orElseThrow(() -> Engine.Err.functionNotFound(func.name));
        return Linker.nativeLinker().downcallHandle(func_ptr, func.descriptor);
    }

}
