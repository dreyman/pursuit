const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const math = std.math;

const fit = @import("../fit/fit.zig");
const calc = @import("../calc.zig");
const geo = @import("../geo.zig");
const ImportResult = @import("../file_import.zig").ImportResult;

pub fn importFitFilePath(
    a: mem.Allocator,
    file_path: []const u8,
) !ImportResult {
    const fit_file = try fs.openFileAbsolute(file_path, .{});
    defer fit_file.close();

    const res = try importFitFile(a, fit_file);
    return res;
}

pub fn importFitFile(
    a: mem.Allocator,
    fit_file: fs.File,
) !ImportResult {
    const fit_activity = try fit.decodeActivityFromFile(a, fit_file);

    var route = routeFromFit(a, fit_activity, .radians);
    var stats = geo.routeStats(route);
    stats.type = routeTypeFromFitSport(fit_activity.session.sport);

    stats.min_lat = math.radiansToDegrees(route.points[0].lat);
    stats.max_lat = math.radiansToDegrees(route.points[0].lat);
    stats.min_lon = math.radiansToDegrees(route.points[0].lon);
    stats.max_lon = math.radiansToDegrees(route.points[0].lon);
    for (0..route.points.len) |i| {
        var p = &route.points[i];
        p.lat = math.radiansToDegrees(p.lat);
        p.lon = math.radiansToDegrees(p.lon);
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

pub fn routeTypeFromFitSport(fit_sport_val: ?u8) geo.Route.Type {
    if (fit_sport_val == null) return .unknown;
    const sport = std.meta.intToEnum(fit.Sport, fit_sport_val.?) catch
        return .unknown;
    return switch (sport) {
        .running => geo.Route.Type.running,
        .cycling => geo.Route.Type.cycling,
        .walking => geo.Route.Type.walking,
        .hiking => geo.Route.Type.hiking,
    };
}
