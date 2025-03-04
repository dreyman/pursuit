const std = @import("std");
const math = std.math;

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
