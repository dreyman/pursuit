const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const math = std.math;

const fit = @import("fit/fit.zig");
const calc = @import("calc.zig");
const geo = @import("geo.zig");
const core = @import("core.zig");

pub fn importGpsFile(
    allocator: mem.Allocator,
    file_path: []const u8,
) !struct { route: geo.Route, stats: geo.Route.Stats } {
    const file = try fs.openFileAbsolute(file_path, .{});
    defer file.close();

    // TODO: for now assume the file is .fit
    const fit_activity = try fit.decodeActivityFromFile(allocator, file);

    var route = routeFromFit(allocator, fit_activity, .radians);
    const stats = geo.routeStats(route);

    for (0..route.points.len) |i| {
        var p = &route.points[i];
        p.lat = math.radiansToDegrees(p.lat);
        p.lon = math.radiansToDegrees(p.lon);
    }

    return .{ .route = route, .stats = stats };
}

pub fn routeFromFit(
    allocator: mem.Allocator,
    activity: fit.Activity,
    unit: geo.CoordUnit,
) geo.Route {
    var route = geo.Route.init(allocator, activity.records.items.len) catch unreachable;
    for (activity.records.items, 0..) |rec, i| {
        route.points[i] = .{
            .lat = calc.convertSemicircles(rec.lat.?, unit),
            .lon = calc.convertSemicircles(rec.lon.?, unit),
        };
        route.timestamps[i] = rec.timestamp + fit.protocol.timestamp_offset;
    }
    return route;
}
