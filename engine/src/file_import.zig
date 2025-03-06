const std = @import("std");
const assert = std.debug.assert;
const fs = std.fs;
const mem = std.mem;
const gzip = std.compress.gzip;

const fit_import = @import("import/fit_import.zig");
const storage = @import("storage.zig");
// const fit = @import("fit/fit.zig");
// const calc = @import("calc.zig");
const geo = @import("geo.zig");

pub const Error = error{UnsupportedFileFormat};

pub const SupportedExtension = enum {
    fit,
    fitgz,
    // gpx,
    // gpxgz,
};

pub const ImportResult = struct {
    route: geo.Route,
    stats: geo.Route.Stats,
};

pub fn importGpsFile(
    a: mem.Allocator,
    file_path: []const u8,
) !ImportResult {
    const ext = getExtension(file_path);
    if (ext == null) return Error.UnsupportedFileFormat;
    switch (ext.?) {
        .fit => {
            return try fit_import.importFitFilePath(a, file_path);
        },
        .fitgz => {
            // fixme delete temp file
            const name = fs.path.basename(file_path);
            assert(mem.endsWith(u8, name, ".gz"));
            const ungzipped_file_name = name[0 .. name.len - 3];
            const ungzipped_file = try storage.createTempFile(a, ungzipped_file_name);
            errdefer ungzipped_file.close();
            const file = try fs.openFileAbsolute(file_path, .{});
            defer file.close();
            try gzip.decompress(file.reader(), ungzipped_file.writer());

            const path = try storage.tempFilePath(a, ungzipped_file_name);
            ungzipped_file.close();
            return try fit_import.importFitFilePath(a, path);
        },
    }
}

pub fn getExtension(path_to_file: []const u8) ?SupportedExtension {
    const name = fs.path.basename(path_to_file);
    if (mem.endsWith(u8, name, ".fit")) return .fit;
    if (mem.endsWith(u8, name, ".fit.gz")) return .fitgz;
    // if (mem.endsWith(u8, name, ".gpx")) return .gpx;
    // if (mem.endsWith(u8, name, ".gpx.gz")) return .gpxgz;
    return null;
}
