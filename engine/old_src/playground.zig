const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const testing = std.testing;

const gpx_import = @import("import/gpx_import.zig");

fn plgrnd(a: mem.Allocator, file: fs.File) !void {
    const res = try gpx_import.importGpxFile(a, file);
    var route = res.route;
    const stats = res.stats;
    defer {
        route.deinit();
    }
    try std.json.stringify(
        stats,
        .{ .whitespace = .indent_4 },
        std.io.getStdOut().writer(),
    );
    std.debug.print("\n", .{});
}

test plgrnd {
    const file = try fs.openFileAbsolute("/home/ihor/code/pursuit/engine/src/temp/gaps.gpx", .{});
    defer file.close();
    try plgrnd(testing.allocator, file);

    try testing.expect(4 == 4);
}
