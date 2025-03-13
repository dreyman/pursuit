const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const math = std.math;

const fit = @import("../fit/fit.zig");
const calc = @import("../calc.zig");
const core = @import("../core.zig");
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
    var route = routeFromFitActivity(a, fit_activity, .radians);
    var stats = core.calcRouteStats(route, .radians);
    stats.type = routeTypeFromFitSport(fit_activity.session.sport);
    stats.start.toDegrees();
    stats.finish.toDegrees();
    stats.westernmost.toDegrees();
    stats.northernmost.toDegrees();
    stats.easternmost.toDegrees();
    stats.southernmost.toDegrees();
    for (0..route.len()) |i| {
        route.lat[i] = math.radiansToDegrees(route.lat[i]);
        route.lon[i] = math.radiansToDegrees(route.lon[i]);
    }
    return .{ .route = route, .stats = stats };
}

fn routeFromFitActivity(
    a: mem.Allocator,
    activity: fit.Activity,
    unit: core.CoordUnit,
) core.Route {
    var route = core.Route.init(a, activity.records.items.len) catch unreachable;
    for (activity.records.items, 0..) |rec, i| {
        route.lat[i] = calc.convertSemicircles(rec.lat.?, unit);
        route.lon[i] = calc.convertSemicircles(rec.lon.?, unit);
        route.time[i] = rec.timestamp + fit.protocol.timestamp_offset;
    }
    return route;
}

fn routeTypeFromFitSport(fit_sport_val: ?u8) core.Route.Type {
    if (fit_sport_val == null) return .unknown;
    const sport = std.meta.intToEnum(fit.Sport, fit_sport_val.?) catch
        return .unknown;
    return switch (sport) {
        .running => .running,
        .cycling => .cycling,
        .walking => .walking,
        .hiking => .hiking,
    };
}
