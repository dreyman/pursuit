const std = @import("std");
const assert = std.debug.assert;
const fs = std.fs;
const mem = std.mem;

const fit_import = @import("import/fit_import.zig");
const gpx_import = @import("import/gpx_import.zig");
const storage = @import("storage.zig");
const core = @import("core.zig");

pub const Error = error{UnsupportedFileFormat};

pub const SupportedExtension = enum {
    fit,
    fitgz,
    gpx,
    gpxgz,
};

pub const ImportResult = struct {
    route: core.Route,
    stats: core.Stats,
};

pub fn importGpsFile(
    a: mem.Allocator,
    file_path: []const u8,
) !ImportResult {
    const ext = getExtension(file_path) orelse return Error.UnsupportedFileFormat;
    switch (ext) {
        .fit => return try fit_import.importFitFilePath(a, file_path),
        .gpx => return try gpx_import.importGpxFilePath(a, file_path),
        .fitgz, .gpxgz => {
            const ungzipped_file = try storage.ungzip(a, file_path);
            defer {
                ungzipped_file.close();
                // storage.deleteTempFile(a, ungzipped_file); // fixme
            }
            if (ext == .fitgz)
                return try fit_import.importFitFile(a, ungzipped_file);
            if (ext == .gpxgz)
                return try gpx_import.importGpxFile(a, ungzipped_file);
            unreachable;
        },
    }
}

fn getExtension(file_path: []const u8) ?SupportedExtension {
    const name = fs.path.basename(file_path);
    if (mem.endsWith(u8, name, ".fit")) return .fit;
    if (mem.endsWith(u8, name, ".fit.gz")) return .fitgz;
    if (mem.endsWith(u8, name, ".gpx")) return .gpx;
    if (mem.endsWith(u8, name, ".gpx.gz")) return .gpxgz;
    return null;
}
