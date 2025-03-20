const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const testing = std.testing;

const activities_csv = @import("strava/activities_csv.zig");
const strava_archive = @import("strava/archive.zig");
const file_import = @import("file_import.zig");
const storage = @import("storage.zig");

fn process(a: mem.Allocator, dir_path: []const u8) !void {
    var dir = try fs.openDirAbsolute(dir_path, .{});
    defer dir.close();
    const activities_csv_content = try dir.readFileAlloc(a, "activities.csv", std.math.maxInt(u64));
    defer a.free(activities_csv_content);

    const csv = try activities_csv.parse(a, activities_csv_content);
    defer csv.deinit();
    for (csv.records.items) |rec| {
        const ac = try strava_archive.activityFromCsvValues(rec.items);
        const acfile_path = try dir.realpathAlloc(a, ac.filename);
        defer a.free(acfile_path);
        const res = try file_import.importGpsFile(a, acfile_path);
        var route = res.route;
        const stats = res.stats;
        defer route.deinit();

        storage.addEntry(
            a,
            acfile_path,
            route,
            stats,
        ) catch |err| switch (err) {
            else => std.debug.print("FAILED for: {s}\n", .{ac.name.?}),
        };

        // std.debug.print("{s} {s}\n", .{ ac.name orelse "NO_NAME", ac.filename });
        // std.debug.print("ID: {d}\n", .{ac.id});
        // std.debug.print("Distance: {d}\t{d}\n", .{ ac.distance, stats.distance });
        // std.debug.print("Elapsed time: {d}\t{d}\n", .{ ac.elapsed_time, stats.total_time });
        // std.debug.print("Moving time: {d}\t{d}\n", .{ ac.moving_time, stats.moving_time });
        // std.debug.print("Avg speed: {d}\t{d}\n", .{ ac.avg_speed, stats.avg_speed });
        // std.debug.print("==================================\n", .{});
    }
}

test process {
    try process(testing.allocator, "/home/ihor/stuff/export_53360041");

    try testing.expect(4 == 4);
}
