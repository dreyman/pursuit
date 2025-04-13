const Stats = @This();

const std = @import("std");

const Route = @import("Route.zig");
const calc = @import("calc.zig");
const geo = @import("geo.zig");
const Distance = geo.Distance;
const Speed = geo.Speed;

start_time: u32,
finish_time: u32,
start: geo.Point,
finish: geo.Point,
distance: Distance.Meters,
total_time: u32,
moving_time: u32,
stops_count: u16,
stops_duration: u32,
untracked_distance: Distance.Meters,
avg_speed: Speed.MetersPerHour,
avg_travel_speed: Speed.MetersPerHour,
westernmost: geo.Point,
northernmost: geo.Point,
easternmost: geo.Point,
southernmost: geo.Point,
size: u32,

// pub const Alg = enum {
//     every_second,
//     min_speed,
//     min_speed_max_time_gap,

//     pub const min_speed_kmh = 4.5;
//     pub const max_time_gap = 10;
// };

pub const CalcStatsOptions = struct {
    min_speed: u8 = 1,
    max_time_gap: u8 = 5,

    pub const every_second = CalcStatsOptions{
        .min_speed = 0,
        .max_time_gap = 1,
    };
};

pub fn fromRoute(
    route: Route,
    unit: geo.Point.Unit,
    options: CalcStatsOptions,
) Stats {
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
        .westernmost = undefined,
        .northernmost = undefined,
        .easternmost = undefined,
        .southernmost = undefined,
        .size = @intCast(route.len()),
    };
    var total_distance: Distance.Km = 0;
    var untracked_distance: Distance.Km = 0;
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
        const time_diff_hours: f64 = @as(f64, @floatFromInt(t2 - t1)) / 3600;
        const speed = distance / time_diff_hours;
        const moving = t2 - t1 <= options.max_time_gap and
            speed >= @as(f64, @floatFromInt(options.min_speed));
        if (moving) {
            total_distance += distance;
        } else {
            stats.stops_count += 1;
            stats.stops_duration += t2 - t1;
            untracked_distance += distance;
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
