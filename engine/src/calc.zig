const std = @import("std");
const math = std.math;

const core = @import("core.zig");
const geo = @import("geo.zig");

pub const earth_r = 6371;

pub fn semicirclesToDegrees(semicircles: i32) f32 {
    return std.math.radiansToDegrees(semicirclesToRadians(semicircles));
}

pub fn semicirclesToRadians(semicircles: i32) f32 {
    return (@as(f32, @floatFromInt(semicircles)) * std.math.pi) / 0x80000000;
}

pub fn convertSemicircles(semicircles: i32, unit: geo.CoordUnit) f32 {
    return switch (unit) {
        .degrees => semicirclesToDegrees(semicircles),
        .radians => semicirclesToRadians(semicircles),
        .semicircles => unreachable,
    };
}

pub fn distance(point1: geo.Point, point2: geo.Point) f64 {
    const dlat: f64 = point1.lat - point2.lat;
    const dlon: f64 = point1.lon - point2.lon;
    const a: f64 = math.pow(f64, math.sin(dlat / 2), 2) + math.cos(point1.lat) * math.cos(point2.lat) * math.pow(f64, math.sin(dlon / 2), 2);
    const c: f64 = 2 * math.asin(math.sqrt(a));
    return c * earth_r;
}

pub fn routeDistance(route: []core.LatLon) f64 {
    if (route.len < 2) return 0;
    var res: f64 = 0;
    for (1..route.len) |i| {
        const prev = route[i - 1];
        const curr = route[i];
        res += distance(prev, curr);
    }
    return res;
}

test distance {
    const point1 = core.LatLon{
        .lat = math.degreesToRadians(48.962677),
        .lon = math.degreesToRadians(32.23204),
    };
    const point2 = core.LatLon{
        .lat = math.degreesToRadians(48.920967),
        .lon = math.degreesToRadians(32.260834),
    };

    const dist = distance(point1, point2);

    try std.testing.expect(5.09 < dist and dist < 5.093);
}
