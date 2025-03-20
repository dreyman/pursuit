const std = @import("std");
const assert = std.debug.assert;
const fs = std.fs;
const mem = std.mem;

const fit_import = @import("import/fit_import.zig");
const gpx_import = @import("import/gpx_import.zig");
const storage = @import("storage.zig");
const core = @import("core.zig");

pub const Error = error{UnsupportedFileFormat};

pub const GpsFileType = enum {
    fit,
    fitgz,
    gpx,
    gpxgz,

    pub fn fromPath(path: []const u8) ?GpsFileType {
        if (mem.endsWith(u8, path, ".fit")) return .fit;
        if (mem.endsWith(u8, path, ".fit.gz")) return .fitgz;
        if (mem.endsWith(u8, path, ".gpx")) return .gpx;
        if (mem.endsWith(u8, path, ".gpx.gz")) return .gpxgz;
        return null;
    }
};

pub const ImportResult = struct {
    route: core.Route,
    stats: core.Stats,
};

pub fn importGpsFile(
    a: mem.Allocator,
    file_path: []const u8,
) !ImportResult {
    const gpsFileType = GpsFileType.fromPath(file_path) orelse
        return Error.UnsupportedFileFormat;
    switch (gpsFileType) {
        .fit => return try fit_import.importFitFilePath(a, file_path),
        .gpx => return try gpx_import.importGpxFilePath(a, file_path),
        .fitgz, .gpxgz => {
            const ungzipped = try storage.ungzip(a, file_path);
            defer {
                ungzipped.close();
                // storage.deleteTempFile(a, ungzipped_file); // fixme
            }
            if (gpsFileType == .fitgz) {
                return try fit_import.importFitFile(a, ungzipped);
            } else {
                return try gpx_import.importGpxFile(a, ungzipped);
            }
        },
    }
}
