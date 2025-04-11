const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;

const fit = @import("fit/fit.zig");
const data = @import("../data.zig");
const calc = @import("../calc.zig");

pub fn decodeRoute(
    alloc: Allocator,
    fit_content: []const u8,
    unit: data.CoordUnit,
) !data.Route {
    var raw_fit = try fit.decode(alloc, fit_content);
    defer raw_fit.deinit();
    var fit_activity = try fit.Activity.create(alloc, raw_fit);
    defer fit_activity.deinit();

    return try routeFromFitActivity(alloc, fit_activity, unit);
}

fn routeFromFitActivity(
    alloc: Allocator,
    activity: fit.Activity,
    unit: data.CoordUnit,
) !data.Route {
    var route = try data.Route.init(alloc, activity.records.items.len);
    for (activity.records.items, 0..) |rec, i| {
        route.lat[i] = calc.convertSemicircles(rec.lat.?, unit);
        route.lon[i] = calc.convertSemicircles(rec.lon.?, unit);
        route.time[i] = rec.timestamp + fit.protocol.timestamp_offset;
    }
    return route;
}

fn kindFromFitSport(fit_sport_val: ?u8) data.Pursuit.Kind {
    if (fit_sport_val == null) return .unknown;
    const sport = std.meta.intToEnum(fit.Sport, fit_sport_val.?) catch
        return .unknown;
    return switch (sport) {
        .running => .running,
        .cycling => .cycling,
        .walking => .walking,
    };
}
