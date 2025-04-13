const std = @import("std");
const builtin = @import("builtin");
const mem = std.mem;

const app = @import("app.zig");
const data = @import("data.zig");
const Pursuit = data.Pursuit;
const Storage = @import("Storage.zig");

// const GPA = std.heap.GeneralPurposeAllocator(.{});
// var gpa = GPA{};
// var alloc = gpa.allocator();

// var gpa: ?GPA = gpa: {
//     if (builtin.link_libc) {
//         if (switch (builtin.mode) {
//             .ReleaseSafe, .ReleaseFast => true,
//             else => false,
//         }) break :gpa null;
//     }

//     break :gpa GPA{};
// };

// const alloc: std.mem.Allocator = if (gpa) |*value|
//     value.allocator()
// else if (builtin.link_libc)
//     std.heap.c_allocator
// else
//     unreachable;

const alloc: std.mem.Allocator = std.heap.c_allocator;

export fn pursuit_version() [*:0]const u8 {
    return app.version;
}

export fn pursuit_import_file(
    file: [*:0]const u8,
    storage_dir: [*:0]const u8,
) Pursuit.ID {
    const storage = Storage.create(alloc, mem.span(storage_dir)) catch |err|
        switch (err) {
        else => return 0,
    };
    const id = app.importGpsFile(alloc, storage, mem.span(file), null) catch |err|
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
    const storage = Storage.create(alloc, mem.span(storage_dir)) catch
        return 1;
    _ = app.recalcStats(storage, id, .{
        .min_speed = min_speed,
        .max_time_gap = max_time_gap,
    }) catch return 1;
    return 0;
}
