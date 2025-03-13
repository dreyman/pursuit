const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const math = std.math;

const gpx = @import("../gpx/gpx.zig");
const calc = @import("../calc.zig");
const core = @import("../core.zig");
const ImportResult = @import("../file_import.zig").ImportResult;

pub fn importGpxFilePath(
    a: mem.Allocator,
    file_path: []const u8,
) !ImportResult {
    const gpx_file = try fs.openFileAbsolute(file_path, .{});
    defer gpx_file.close();

    const res = try importGpxFile(a, gpx_file);
    return res;
}

pub fn importGpxFile(
    a: mem.Allocator,
    gpx_file: fs.File,
) !ImportResult {
    const stat = try gpx_file.stat();
    const bytes: []u8 = try gpx_file.readToEndAlloc(a, stat.size);
    defer a.free(bytes);

    const gpx_data = try gpx.parse(a, bytes);
    const route = routeFromGpx(a, gpx_data);
    var stats = core.routeStats(route, .degrees);
    stats.type = routeTypeFromGpxType(gpx_data.type);

    stats.min_lat = route.points[0].lat;
    stats.max_lat = route.points[0].lat;
    stats.min_lon = route.points[0].lon;
    stats.max_lon = route.points[0].lon;
    for (route.points) |p| {
        if (p.lat < stats.min_lat) {
            stats.min_lat = p.lat;
        } else if (p.lat > stats.max_lat) {
            stats.max_lat = p.lat;
        }
        if (p.lon < stats.min_lon) {
            stats.min_lon = p.lon;
        } else if (p.lon > stats.max_lon) {
            stats.max_lon = p.lon;
        }
    }
    return .{ .route = route, .stats = stats };
}

pub fn routeFromGpx(allocator: mem.Allocator, gpx_data: gpx.Gpx) core.Route {
    var route = core.Route.init(allocator, gpx_data.track.items.len) catch unreachable;
    for (gpx_data.track.items, 0..) |trkpt, i| {
        route.points[i] = .{
            .lat = @floatCast(trkpt.lat),
            .lon = @floatCast(trkpt.lon),
        };
        route.timestamps[i] = trkpt.time;
    }
    return route;
}

pub fn routeTypeFromGpxType(gpx_type: ?gpx.Gpx.Type) core.Route.Type {
    if (gpx_type == null) return .unknown;
    return switch (gpx_type.?) {
        .cycling => .cycling,
        .running => .running,
    };
}
