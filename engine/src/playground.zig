const std = @import("std");
const mem = std.mem;
const fs = std.fs;

const GpsFile = @import("GpsFile.zig");
const gpxfile = @import("gpsfile/gpxfile.zig");

fn oldAlg(
    alloc: mem.Allocator,
    file: []const u8,
) !*GpsFile {
    const content = try fs.cwd().readFileAlloc(alloc, file, 100_000_000);
    defer alloc.free(content);
    const res = try gpxfile.parse(alloc, content);
    const stats = res.stats;
    std.debug.print("Kind: {s}\n", .{@tagName(res.kind)});
    std.debug.print("Dist: {d}\n", .{stats.distance});
    std.debug.print("Stops: {d} {d}\n", .{ stats.stops_count, stats.stops_duration });

    return res;
}

test "gpx" {
    const t = std.testing;
    const file = "/home/ihor/shealth-hya.gpx";
    var gpsfile = try oldAlg(t.allocator, file);
    defer gpsfile.destroy();

    try t.expect(4 == 4);
}
