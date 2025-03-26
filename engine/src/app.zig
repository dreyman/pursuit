const std = @import("std");
const posix = std.posix;
const fs = std.fs;
const mem = std.mem;
const Allocator = std.mem.Allocator;

const default = @import("default_data.zig");
const Storage = @import("Storage.zig");
const data = @import("data.zig");
const Pursuit = data.Pursuit;
const GpsFile = @import("GpsFile.zig");
const util = @import("util.zig");

const ImportError = error{UnknownKindOfPursuit};

pub fn importGpsFile(alloc: Allocator, file: []const u8) !u32 {
    var storage = try Storage.create(alloc);
    defer storage.destroy();
    const gps_file = try GpsFile.create(alloc, storage, file);
    defer alloc.destroy(gps_file);

    var pursuit = try initEntry(alloc, gps_file);
    defer pursuit.destroy();

    if (pursuit.kind == .unknown) return ImportError.UnknownKindOfPursuit;

    try storage.saveEntry(
        file,
        pursuit,
        gps_file,
        default.Medium.defaultForPursuitKind(pursuit.kind).?.id,
    );
    return pursuit.id;
}

fn initEntry(alloc: Allocator, gps_file: *const GpsFile) !*Pursuit {
    const p = try alloc.create(Pursuit);
    p.* = .{
        .alloc = alloc,
        .id = 0,
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
