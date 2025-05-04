const std = @import("std");
const builtin = @import("builtin");
const mem = std.mem;

const app = @import("app.zig");
const query = @import("query.zig");
const setup = @import("setup.zig");
const data = @import("data.zig");
const geo = @import("geo.zig");
const Pursuit = data.Pursuit;
const Storage = @import("Storage.zig");

const gpa: std.mem.Allocator = std.heap.c_allocator;

export fn pursuit_version() [*:0]const u8 {
    return app.version;
}

export fn pursuit_import_file(
    file: [*:0]const u8,
    storage_dir: [*:0]const u8,
) Pursuit.ID {
    const storage = Storage.create(gpa, mem.span(storage_dir)) catch |err|
        switch (err) {
        else => return 0,
    };
    const id = app.importGpsFile(gpa, storage, mem.span(file), null) catch |err|
        switch (err) {
        else => return 0,
    };
    return id;
}

export fn pursuit_recalc_stats(
    storage_dir: [*:0]const u8,
    id: Pursuit.ID,
    min_speed: u8,
    max_time_gap: u8,
) u8 {
    const storage = Storage.create(gpa, mem.span(storage_dir)) catch
        return 1;
    _ = app.recalcStats(storage, id, .{
        .min_speed = min_speed,
        .max_time_gap = max_time_gap,
    }) catch return 1;
    return 0;
}

export fn pursuit_location_flybys(
    storage_dir: [*:0]const u8,
    lat: f32,
    lon: f32,
    max_distance: geo.Distance.Km,
    time_gap: u32,
) ?[*:0]u8 {
    const max_count = 20;
    const storage = Storage.create(gpa, mem.span(storage_dir)) catch
        return null;
    var json_list = query.findLocationFlybysJson(
        gpa,
        storage,
        .{ .lat = lat, .lon = lon },
        max_distance,
        max_count,
        time_gap,
    ) catch
        return null;
    return json_list.toOwnedSliceSentinel(0) catch
        return null;
}

export fn pursuit_free_str(str: [*:0]u8) void {
    gpa.free(mem.span(str));
}

export fn pursuit_init(storage_dir: [*:0]u8) u8 {
    const allocator = gpa;

    const path = allocator.dupe(u8, mem.sliceTo(storage_dir, 0)) catch
        return 1;
    defer allocator.free(path);
    setup.install(allocator, path) catch
        return 1;
    return 0;
}
