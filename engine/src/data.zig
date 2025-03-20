const std = @import("std");
const mem = std.mem;
const math = std.math;

const calc = @import("calc.zig");

pub const max_time_gap = 3;

pub const Speed = struct {
    pub const MetersPerHour = u21;
};

pub const Distance = struct {
    pub const Km = f64;
    pub const Meters = u32;
};

pub const Pursuit = struct {
    id: u32,
    name: []const u8,
    description: []const u8,
    kind: Kind,
    bike_id: u32,

    pub const Kind = enum { cycling, running, walking, hiking, unknown };
};

pub const Bike = struct {
    id: u32,
    name: []const u8,
};

pub const Route = struct {
    allocator: mem.Allocator,
    lat: []f32,
    lon: []f32,
    time: []u32,

    pub fn init(a: mem.Allocator, size: usize) !Route {
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

    pub fn point(route: *const Route, i: usize) Point {
        return .{
            .lat = route.lat[i],
            .lon = route.lon[i],
        };
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

    pub fn toDegrees(route: *Route) void {
        for (0..route.len()) |i| {
            route.lat[i] = math.radiansToDegrees(route.lat[i]);
            route.lon[i] = math.radiansToDegrees(route.lon[i]);
        }
    }

    pub fn len(route: *const Route) usize {
        return route.time.len;
    }
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
    avg_speed: Speed.MetersPerHour,
    avg_travel_speed: Speed.MetersPerHour,
    // max_speed: Speed.MetersPerHour,
    westernmost: Point,
    northernmost: Point,
    easternmost: Point,
    southernmost: Point,
    size: u32,

    pub fn fromRoute(route: Route, unit: CoordUnit) Stats {
        var stats = Stats{
            .start_time = route.time[0],
            .finish_time = route.time[route.time.len - 1],
            .start = route.startPoint(),
            .finish = route.finishPoint(),
            .distance = 0,
            .total_time = route.time[route.time.len - 1] - route.time[0],
            .moving_time = 0,
            .stops_count = 0,
            .stops_duration = 0,
            .untracked_distance = 0,
            .avg_speed = 0,
            .avg_travel_speed = 0,
            // .max_speed = 0,
            .westernmost = undefined,
            .northernmost = undefined,
            .easternmost = undefined,
            .southernmost = undefined,
            .size = @intCast(route.len()),
        };
        var total_distance: Distance.Km = 0;
        var untracked_distance: Distance.Km = 0;
        // var longest_gap: f64 = 0;
        var westernmost_idx: usize = 0;
        var easternmost_idx: usize = 0;
        var southernmost_idx: usize = 0;
        var northernmost_idx: usize = 0;
        for (1..route.len()) |i| {
            const curlat = route.lat[i];
            const curlon = route.lon[i];
            const prevlat = route.lat[i - 1];
            const prevlon = route.lon[i - 1];
            const t1 = route.time[i - 1];
            const t2 = route.time[i];
            const distance = switch (unit) {
                .radians => calc.distanceRadians(prevlat, prevlon, curlat, curlon),
                .degrees => calc.distanceDegrees(prevlat, prevlon, curlat, curlon),
            };
            if (t2 - t1 > max_time_gap) {
                stats.stops_count += 1;
                stats.stops_duration += t2 - t1;
                untracked_distance += distance;
            } else {
                total_distance += distance;
                // if (distance > longest_gap) longest_gap = distance;
            }
            if (curlon < route.lon[westernmost_idx]) westernmost_idx = i;
            if (curlon > route.lon[easternmost_idx]) easternmost_idx = i;
            if (curlat > route.lat[northernmost_idx]) northernmost_idx = i;
            if (curlat < route.lat[southernmost_idx]) southernmost_idx = i;
        }
        stats.westernmost = route.point(westernmost_idx);
        stats.easternmost = route.point(easternmost_idx);
        stats.southernmost = route.point(southernmost_idx);
        stats.northernmost = route.point(northernmost_idx);
        stats.distance = @intFromFloat(total_distance * 1_000);
        stats.untracked_distance = @intFromFloat(untracked_distance * 1_000);
        stats.moving_time = stats.total_time - stats.stops_duration;
        stats.avg_speed = calc.avgSpeed(total_distance, stats.moving_time);
        stats.avg_travel_speed = calc.avgSpeed(total_distance, stats.total_time);
        // stats.max_speed = calc.avgSpeed(longest_gap, 1);
        return stats;
    }

    pub fn toDegrees(stats: *Stats) void {
        stats.start.toDegrees();
        stats.finish.toDegrees();
        stats.westernmost.toDegrees();
        stats.northernmost.toDegrees();
        stats.easternmost.toDegrees();
        stats.southernmost.toDegrees();
    }
};
