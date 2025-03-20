const std = @import("std");
const posix = std.posix;
const fs = std.fs;
const Allocator = std.mem.Allocator;

const Storage = @import("Storage.zig");
const data = @import("data.zig");
const Pursuit = data.Pursuit;
const GpsFile = @import("GpsFile.zig");

const storage_dir_name = ".pursuit";
const db_file_name = "pursuit.db";
const default_bike_id = 0;

pub const SetupError = error{HomeDirNotFound};

pub fn setup(alloc: Allocator) !void {
    try Storage.setup(alloc);
}

pub fn importGpsFile(alloc: Allocator, file: []const u8) !void {
    const gps_file = try GpsFile.create(alloc, file);
    defer alloc.destroy(gps_file);
    var pursuit = try initEntry(gps_file);
    var storage = try Storage.create(alloc);
    defer storage.destroy();
    try storage.createEntry(file, &pursuit, gps_file);

    // std.debug.print("{s}\n", .{@tagName(gps_file.kind)});
    // std.debug.print("route len = {d}\n", .{gps_file.route.len()});
    // std.debug.print("distance = {d}\n", .{gps_file.stats.distance});
}

fn initEntry(gps_file: *const GpsFile) !Pursuit {
    return .{
        .id = 0,
        .bike_id = default_bike_id,
        .name = "TODO: Generate proper name",
        .description = "",
        .kind = gps_file.kind,
    };
}
