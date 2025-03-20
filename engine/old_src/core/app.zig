const std = @import("std");
const posix = std.posix;
const fs = std.fs;
const mem = std.mem;
const Allocator = std.mem.Allocator;

const database = @import("database.zig");

const storage_dir_name = ".pursuit";
const db_file_name = "pursuit.db";
const max_file_size = 50_000_000;

pub const SetupError = error{HomeDirNotFound};

pub fn setup(alloc: Allocator) !void {
    const home_path = posix.getenv("HOME") orelse
        return SetupError.HomeDirNotFound;
    var home = try fs.openDirAbsolute(home_path, .{});
    defer home.close();
    try home.makeDir(storage_dir_name);

    const db_file_path = try fs.path.joinZ(
        alloc,
        &.{ home_path, storage_dir_name, db_file_name },
    );
    try database.setup(db_file_path);
}

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
