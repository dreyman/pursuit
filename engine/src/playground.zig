const std = @import("std");
const mem = std.mem;
const fs = std.fs;

const data = @import("data.zig");
const gpxfile = @import("gpsfile/gpxfile.zig");
const fitfile = @import("gpsfile/fitfile.zig");

fn decodeFit(
    alloc: mem.Allocator,
    content: []const u8,
) !data.Route {
    const res = try fitfile.decodeRoute(alloc, content, .radians);

    return res;
}

fn parseGpx(
    alloc: mem.Allocator,
    content: []const u8,
) !data.Route {
    const res = try gpxfile.parseRoute(alloc, content);

    return res;
}

test "trouble" {
    const t = std.testing;
    const alloc = t.allocator;
    const file = "/home/ihor/code/pursuit/dev/7938630382.fit";
    const fit_content = try std.fs.cwd().readFileAlloc(alloc, file, 100_000_000);
    var r = try fitfile.decodeRoute(alloc, fit_content, .radians);
    defer r.deinit();
    const util = struct {
        pub fn detectAlg(route: data.Route) data.Stats.Alg {
            for (1..route.time.len) |i| {
                if (route.time[i] - route.time[i - 1] == 1) return .every_second;
            }
            return .min_speed;
        }
    };
    const s = data.Stats.fromRoute(r, .radians, util.detectAlg(r));
    _ = s;

    try t.expect(4 == 4);
}

test "just" {
    const t = std.testing;
    const alloc = t.allocator;
    const file = "/home/ihor/code/pursuit/dev/10287226915.fit";
    const is_fit = comptime std.mem.eql(u8, "fit", file[file.len - 3 ..]);
    const content = try fs.cwd().readFileAlloc(alloc, file, 100_000_000);
    defer {
        if (!is_fit) alloc.free(content);
    }

    var r = if (is_fit)
        try decodeFit(t.allocator, content)
    else
        try parseGpx(t.allocator, content);
    defer r.deinit();

    const alg = if (is_fit) .every_second else .min_speed;
    var s = data.Stats.fromRoute(r, .radians, alg);
    r.toDegrees();
    s.toDegrees();

    // std.debug.print("Kind: {s}\n", .{@tagName(kind)});
    std.debug.print("Route size: {d}\n", .{r.time.len});
    std.debug.print("Dist: {d}\n", .{s.distance});
    try std.json.stringify(
        s,
        .{ .whitespace = .indent_4 },
        std.io.getStdOut().writer(),
    );

    std.debug.print("\n\n", .{});
    try t.expect(4 == 4);
}
