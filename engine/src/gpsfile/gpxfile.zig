const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

const data = @import("../data.zig");
const GpsFile = @import("../GpsFile.zig");
const gpx = @import("gpx/gpx.zig");

pub fn parse(
    alloc: Allocator,
    gpx_content: []const u8,
) !*GpsFile {
    const gpx_data = try gpx.parse(alloc, gpx_content);
    defer gpx_data.deinit();
    const route = routeFromGpx(alloc, gpx_data);
    const stats = data.Stats.fromRoute(route, .degrees);
    const kind = kindFromGpxType(gpx_data.type);
    const result = try alloc.create(GpsFile);
    result.* = .{
        .route = route,
        .stats = stats,
        .kind = kind,
    };
    return result;
}

pub fn routeFromGpx(alloc: Allocator, gpx_data: gpx.Gpx) data.Route {
    var route = data.Route.init(alloc, gpx_data.track.items.len) catch unreachable;
    for (gpx_data.track.items, 0..) |trkpt, i| {
        route.lat[i] = @floatCast(trkpt.lat);
        route.lon[i] = @floatCast(trkpt.lon);
        route.time[i] = trkpt.time;
    }
    return route;
}

pub fn kindFromGpxType(gpx_type: ?gpx.Gpx.Type) data.Pursuit.Kind {
    if (gpx_type == null) return .unknown;
    return switch (gpx_type.?) {
        .cycling => .cycling,
        .running => .running,
    };
}
