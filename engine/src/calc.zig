const std = @import("std");
const math = std.math;
const testing = std.testing;
const cos = math.cos;
const sin = math.sin;
const pow = math.pow;
const asin = math.asin;
const sqrt = math.sqrt;

const geo = @import("geo.zig");
const Distance = geo.Distance;
const Speed = geo.Speed;

pub const earth_r = 6371;

pub fn semicirclesToDegrees(semicircles: i32) f32 {
    return std.math.radiansToDegrees(semicirclesToRadians(semicircles));
}

pub fn semicirclesToRadians(semicircles: i32) f32 {
    return (@as(f32, @floatFromInt(semicircles)) * std.math.pi) / 0x80000000;
}

pub fn convertSemicircles(semicircles: i32, unit: geo.Point.Unit) f32 {
    return switch (unit) {
        .degrees => semicirclesToDegrees(semicircles),
        .radians => semicirclesToRadians(semicircles),
    };
}

pub fn distanceRadians(lat1: f32, lon1: f32, lat2: f32, lon2: f32) Distance.Km {
    const dlat: f64 = lat1 - lat2;
    const dlon: f64 = lon1 - lon2;
    const a: f64 = pow(f64, sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(f64, sin(dlon / 2), 2);
    const c: f64 = 2 * asin(sqrt(a));
    return c * earth_r;
}

pub fn distanceDegrees(lat1: f32, lon1: f32, lat2: f32, lon2: f32) Distance.Km {
    return distanceRadians(
        math.degreesToRadians(lat1),
        math.degreesToRadians(lon1),
        math.degreesToRadians(lat2),
        math.degreesToRadians(lon2),
    );
}

test distanceDegrees {
    const dist = distanceDegrees(49.246223, 30.101769, 48.888504, 30.697052);
    try testing.expect(58.84 < dist and dist < 58.85);
}

pub fn avgSpeed(distance_km: Distance.Km, time_seconds: u32) Speed.MetersPerHour {
    const kmh = distance_km / (@as(f64, @floatFromInt(time_seconds)) / 3_600);
    return @intFromFloat(kmh * 1_000);
}

test avgSpeed {
    try testing.expect(avgSpeed(30, 3_600 * 2) == 15_000);
}
