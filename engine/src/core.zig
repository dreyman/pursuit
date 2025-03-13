const std = @import("std");
const assert = std.debug.assert;
const mem = std.mem;
const math = std.math;
const testing = std.testing;

const calc = @import("calc.zig");

pub const Speed = struct {
    pub const MetersPerHour = u21;
};

pub const Distance = struct {
    pub const Km = f64;
    pub const Meters = u32;
};

pub const Route = struct {
    allocator: mem.Allocator,
    lat: []f32,
    lon: []f32,
    time: []u32,
    // temperature: []i8,
    // altitude: []i32,
    // hr: []u8,
    // cadence: []u8

    pub fn init(a: mem.Allocator, size: usize) !Route {
        assert(size > 0);
        return .{
            .allocator = a,
            .lat = try a.alloc(f32, size),
            .lon = try a.alloc(f32, size),
            .time = try a.alloc(u32, size),
        };
    }

    pub fn deinit(r: *Route) void {
        r.allocator.free(r.lat);
        r.allocator.free(r.lon);
        r.allocator.free(r.time);
    }

    pub fn startPoint(route: *const Route) Point {
        return .{
            .lat = route.lat[0],
            .lon = route.lon[0],
        };
    }

    pub fn finishPoint(route: *const Route) Point {
        return .{
            .lat = route.lat[route.lat.len - 1],
            .lon = route.lon[route.lon.len - 1],
        };
    }

    pub fn len(route: *const Route) usize {
        return route.time.len;
    }

    pub const Type = enum { cycling, running, walking, hiking, unknown };
};

pub const Point = struct {
    lat: f32,
    lon: f32,

    pub fn toDegrees(point: *Point) void {
        point.lat = math.radiansToDegrees(point.lat);
        point.lon = math.radiansToDegrees(point.lon);
    }

    pub fn toRadians(point: *Point) void {
        point.lat = math.degreesToRadians(point.lat);
        point.lon = math.degreesToRadians(point.lon);
    }
};

pub const CoordUnit = enum {
    degrees,
    radians,
};

pub const Stats = struct {
    type: Route.Type,
    start_time: u32,
    finish_time: u32,
    start: Point,
    finish: Point,
    distance: Distance.Meters,
    total_time: u32,
    moving_time: u32,
    stops_count: u16,
    stops_duration: u32,
    untracked_distance: Distance.Meters,
    avg_moving_speed: Speed.MetersPerHour,
    avg_travel_speed: Speed.MetersPerHour,
    // max_speed: Speed.MetersPerHour,
    westernmost: Point,
    northernmost: Point,
    easternmost: Point,
    southernmost: Point,
};

pub fn calcRouteStats(route: Route, unit: CoordUnit) Stats {
    var stats = Stats{
        .type = .unknown,
        .start_time = route.time[0],
        .finish_time = route.time[route.time.len - 1],
        .start = route.startPoint(),
        .finish = route.finishPoint(),
        .distance = 0,
        .total_time = 0,
        .moving_time = 0,
        .stops_count = 0,
        .stops_duration = 0,
        .untracked_distance = 0,
        .avg_moving_speed = 0,
        .avg_travel_speed = 0,
        // .max_speed = 0,
        .westernmost = undefined,
        .northernmost = undefined,
        .easternmost = undefined,
        .southernmost = undefined,
    };
    var total_distance: Distance.Km = 0;
    var untracked_distance: Distance.Km = 0;
    // var longest_gap: f64 = 0;
    var westernmost_idx: usize = 0;
    var easternmost_idx: usize = 0;
    var southernmost_idx: usize = 0;
    var northernmost_idx: usize = 0;
    for (1..route.len()) |i| {
        const cur_lat = route.lat[i];
        const cur_lon = route.lon[i];
        const prev_lat = route.lat[i - 1];
        const prev_lon = route.lon[i - 1];
        const t1 = route.time[i - 1];
        const t2 = route.time[i];
        const distance = switch (unit) {
            .radians => calc.distanceRadians(prev_lat, prev_lon, cur_lat, cur_lon),
            .degrees => calc.distanceDegrees(prev_lat, prev_lon, cur_lat, cur_lon),
        };
        if (t2 - t1 > 1) {
            stats.stops_count += 1;
            stats.stops_duration += t2 - t1;
            untracked_distance += distance;
        } else {
            total_distance += distance;
            // if (distance > longest_gap) longest_gap = distance;
        }
        if (cur_lon < route.lon[westernmost_idx]) westernmost_idx = i;
        if (cur_lon > route.lon[easternmost_idx]) easternmost_idx = i;
        if (cur_lat > route.lat[northernmost_idx]) northernmost_idx = i;
        if (cur_lat < route.lat[southernmost_idx]) southernmost_idx = i;
    }
    stats.westernmost = Point{ .lat = route.lat[westernmost_idx], .lon = route.lon[westernmost_idx] };
    stats.easternmost = Point{ .lat = route.lat[easternmost_idx], .lon = route.lon[easternmost_idx] };
    stats.southernmost = Point{ .lat = route.lat[southernmost_idx], .lon = route.lon[southernmost_idx] };
    stats.northernmost = Point{ .lat = route.lat[northernmost_idx], .lon = route.lon[northernmost_idx] };
    stats.distance = @intFromFloat(total_distance * 1_000);
    stats.untracked_distance = @intFromFloat(untracked_distance * 1_000);
    stats.total_time = route.time[route.time.len - 1] - route.time[0];
    stats.moving_time = stats.total_time - stats.stops_duration;
    stats.avg_moving_speed = calc.avgSpeed(total_distance, stats.moving_time);
    stats.avg_travel_speed = calc.avgSpeed(total_distance, stats.total_time);
    // stats.max_speed = calc.avgSpeed(longest_gap, 1);
    return stats;
}
