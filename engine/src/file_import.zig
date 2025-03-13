const std = @import("std");
const assert = std.debug.assert;
const fs = std.fs;
const mem = std.mem;
const gzip = std.compress.gzip;

const fit_import = @import("import/fit_import.zig");
const gpx_import = @import("import/gpx_import.zig");
const storage = @import("storage.zig");
const core = @import("core.zig");

pub const Error = error{UnsupportedFileFormat};

pub const SupportedExtension = enum {
    fit,
    fitgz,
    gpx,
    // gpxgz,
};

pub const ImportResult = struct {
    route: core.Route,
    stats: core.Stats,
};

pub fn importGpsFile(
    a: mem.Allocator,
    file_path: []const u8,
) !ImportResult {
    const ext = getExtension(file_path);
    if (ext == null) return Error.UnsupportedFileFormat;
    switch (ext.?) {
        .fit => return try fit_import.importFitFilePath(a, file_path),
        .gpx => return try gpx_import.importGpxFilePath(a, file_path),
        .fitgz => {
            const name = fs.path.basename(file_path);
            assert(mem.endsWith(u8, name, ".gz"));
            const ungzipped_file_name = name[0 .. name.len - ".gz".len];
            const ungzipped_file = try storage.createTempFile(a, ungzipped_file_name, .{ .read = true });
            const file = try fs.openFileAbsolute(file_path, .{});
            defer {
                ungzipped_file.close();
                file.close();
                storage.deleteTempFile(a, ungzipped_file_name) catch
                    std.debug.print("failed to delete temp file\n", .{});
            }

            try gzip.decompress(file.reader(), ungzipped_file.writer());
            try ungzipped_file.seekTo(0);
            return try fit_import.importFitFile(a, ungzipped_file);
        },
    }
}

pub fn getExtension(file_path: []const u8) ?SupportedExtension {
    const name = fs.path.basename(file_path);
    if (mem.endsWith(u8, name, ".fit")) return .fit;
    if (mem.endsWith(u8, name, ".fit.gz")) return .fitgz;
    if (mem.endsWith(u8, name, ".gpx")) return .gpx;
    // if (mem.endsWith(u8, name, ".gpx.gz")) return .gpxgz;
    return null;
}
