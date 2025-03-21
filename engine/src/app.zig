const std = @import("std");
const posix = std.posix;
const fs = std.fs;
const mem = std.mem;
const Allocator = std.mem.Allocator;

const Storage = @import("Storage.zig");
const data = @import("data.zig");
const Pursuit = data.Pursuit;
const GpsFile = @import("GpsFile.zig");
const util = @import("util.zig");

const storage_dir_name = ".pursuit";
const db_file_name = "pursuit.db";
const default_bike_id = 0;

pub fn setup(alloc: Allocator) !void {
    try Storage.setup(alloc);
}

pub fn importGpsFile(alloc: Allocator, file: []const u8) !void {
    var storage = try Storage.create(alloc);
    defer storage.destroy();
    const gps_file = try GpsFile.create(alloc, storage, file);
    defer alloc.destroy(gps_file);

    var pursuit = try initEntry(alloc, gps_file);
    defer pursuit.destroy();

    try storage.createEntry(file, pursuit, gps_file);
}

fn initEntry(alloc: Allocator, gps_file: *const GpsFile) !*Pursuit {
    const p = try alloc.create(Pursuit);
    p.* = .{
        .alloc = alloc,
        .id = 0,
        .bike_id = default_bike_id,
        .name = try util.generateName(
            alloc,
            gps_file.stats.distance,
            gps_file.stats.start_time,
            gps_file.kind,
        ),
        .description = "",
        .kind = gps_file.kind,
    };
    return p;
}
