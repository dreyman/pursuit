const std = @import("std");
const mem = std.mem;

const calc = @import("calc.zig");

pub const Point = struct {
    lat: f32,
    lon: f32,
};

pub const Route = struct {
    points: []Point,
    timestamps: []u32,
    allocator: mem.Allocator,

    pub fn init(alloc: mem.Allocator, size: usize) !Route {
        return .{
            .allocator = alloc,
            .points = try alloc.alloc(Point, size),
            .timestamps = try alloc.alloc(u32, size),
        };
    }

    pub fn deinit(r: *Route) void {
        r.allocator.free(r.points);
        r.allocator.free(r.timestamps);
    }

    pub const Stats = struct {
        route_type: Route.Type,
        start: u32,
        end: u32,
        distance: u32,
        total_time: u32,
        moving_time: u32,
        stops_count: u16,
        stops_duration: u32,
        untracked_distance: u32,
        min_lat: f32,
        max_lat: f32,
        min_lon: f32,
        max_lon: f32,
    };

    pub const Type = enum { cycling, running, walking, hiking, unknown };
};

pub const CoordUnit = enum {
    semicircles,
    degrees,
    radians,
};

pub fn routeStats(route: Route) Route.Stats {
    var stats: Route.Stats = .{
        .route_type = .unknown,
        .start = route.timestamps[0],
        .end = route.timestamps[route.timestamps.len - 1],
        .distance = 0,
        .total_time = 0,
        .moving_time = 0,
        .stops_count = 0,
        .stops_duration = 0,
        .untracked_distance = 0,
        .min_lat = route.points[0].lat,
        .max_lat = route.points[0].lat,
        .min_lon = route.points[0].lon,
        .max_lon = route.points[0].lon,
    };
    var distance: f64 = 0;
    var untracked_distance: f64 = 0;
    if (route.points.len < 2) return stats;
    for (1..route.points.len) |i| {
        const cur = route.points[i];
        const prev = route.points[i - 1];
        const t1 = route.timestamps[i - 1];
        const t2 = route.timestamps[i];
        if (t2 - t1 > 1) {
            stats.stops_count += 1;
            stats.stops_duration += t2 - t1;
            untracked_distance += calc.distance(prev, cur);
        } else {
            distance += calc.distance(prev, cur);
        }
        if (cur.lat > stats.max_lat) stats.max_lat = cur.lat;
        if (cur.lat < stats.min_lat) stats.min_lat = cur.lat;
        if (cur.lon > stats.max_lon) stats.max_lon = cur.lon;
        if (cur.lon < stats.min_lon) stats.min_lat = cur.lon;
    }
    stats.distance = @intFromFloat(distance * 100);
    stats.untracked_distance = @intFromFloat(untracked_distance * 100);
    stats.total_time = route.timestamps[route.timestamps.len - 1] - route.timestamps[0];
    stats.moving_time = stats.total_time - stats.stops_duration;
    return stats;
}
