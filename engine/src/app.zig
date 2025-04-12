const std = @import("std");
const assert = std.debug.assert;
const posix = std.posix;
const fs = std.fs;
const mem = std.mem;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const constants = @import("constants.zig");
const Storage = @import("Storage.zig");
const data = @import("data.zig");
const geo = @import("geo.zig");
const Pursuit = data.Pursuit;
const Stats = @import("Stats.zig");
const Route = @import("Route.zig");
const Medium = data.Medium;
const fitfile = @import("gpsfile/fitfile.zig");
const gpxfile = @import("gpsfile/gpxfile.zig");
const util = @import("util.zig");

pub const version = "0.0.1-wip";
pub const supported_files = files: {
    var str: []const u8 = "";
    for (std.meta.fields(GpsFileType), 0..) |ext, i| {
        if (i > 0) str = str ++ ", ";
        str = str ++ "." ++ ext.name ++ ", ." ++ ext.name ++ ".gz";
    }
    break :files str;
};

pub const GpsFileType = enum {
    fit,
    gpx,

    pub fn fromPath(path: []const u8) ?GpsFileType {
        if (mem.endsWith(u8, path, ".fit")) return .fit;
        if (mem.endsWith(u8, path, ".gpx")) return .gpx;
        return null;
    }

    pub fn maxFileSize(filetype: GpsFileType) u32 {
        return switch (filetype) {
            .fit => constants.fit_file_size_max,
            .gpx => constants.gpx_file_size_max,
        };
    }
};

pub fn defaultStorageDirPath(gpa: Allocator) ![]const u8 {
    const home_path = posix.getenv("HOME") orelse
        return Storage.Error.HomeDirNotFound;
    const storage_dir_path = try fs.path.join(
        gpa,
        &.{ home_path, Storage.storage_dir_name },
    );
    return storage_dir_path;
}

const ImportError = error{ UnsupportedFileType, RouteTooShort };

pub fn importGpsFile(
    alloc: Allocator,
    storage: *Storage,
    file_path: []const u8,
    pursuit: ?Pursuit,
) !Pursuit.ID {
    const gzipped = mem.endsWith(u8, file_path, ".gz");
    const filetype = GpsFileType.fromPath(if (gzipped)
        file_path[0 .. file_path.len - ".gz".len]
    else
        file_path) orelse
        return ImportError.UnsupportedFileType;

    var file = if (gzipped)
        try storage.ungzip(file_path)
    else
        try fs.cwd().openFile(file_path, .{});
    defer {
        file.close();
        if (gzipped) {
            const filename = fs.path.basename(file_path[0 .. file_path.len - ".gz".len]);
            storage.deleteTempFile(filename) catch
                std.log.info("Failed to delete temp file: {s}", .{filename});
        }
    }

    const file_content = try file.readToEndAlloc(alloc, filetype.maxFileSize());
    defer switch (filetype) {
        .fit => {},
        .gpx => alloc.free(file_content),
    };
    const coords_unit: geo.Point.Unit = switch (filetype) {
        .fit => .radians,
        .gpx => .degrees,
    };
    var route = switch (filetype) {
        .fit => try fitfile.decodeRoute(alloc, file_content, coords_unit),
        .gpx => try gpxfile.parseRoute(alloc, file_content),
    };
    defer route.deinit();
    if (route.len() < constants.route_len_min)
        return ImportError.RouteTooShort;
    var stats = Stats.fromRoute(route, coords_unit, .{});
    if (filetype == .fit) {
        route.toDegrees();
        stats.toDegrees();
    }

    const p = pursuit orelse Pursuit{
        .id = 0,
        .name = try util.generateName(alloc, stats.distance, stats.start_time, .unknown),
        .description = "",
        .kind = .unknown,
        .medium_id = null,
    };
    defer if (pursuit == null) alloc.free(p.name);

    return try storage.saveEntry(file_path, p, route, stats);
}

pub fn recalcStats(
    storage: *Storage,
    id: Pursuit.ID,
    options: Stats.CalcStatsOptions,
) !Stats {
    var route = try storage.getRoute(id);
    defer route.deinit();
    const stats = Stats.fromRoute(route, .degrees, options);
    try storage.db.updateStats(id, stats);
    return stats;
}
