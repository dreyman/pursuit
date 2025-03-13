const std = @import("std");
const math = std.math;
const testing = std.testing;

const core = @import("core.zig");
const Distance = core.Distance;
const Speed = core.Speed;

pub const earth_r = 6371;

pub fn semicirclesToDegrees(semicircles: i32) f32 {
    return std.math.radiansToDegrees(semicirclesToRadians(semicircles));
}

pub fn semicirclesToRadians(semicircles: i32) f32 {
    return (@as(f32, @floatFromInt(semicircles)) * std.math.pi) / 0x80000000;
}

pub fn convertSemicircles(semicircles: i32, unit: core.CoordUnit) f32 {
    return switch (unit) {
        .degrees => semicirclesToDegrees(semicircles),
        .radians => semicirclesToRadians(semicircles),
    };
}

pub fn distance(lat1: f32, lon1: f32, lat2: f32, lon2: f32) Distance.km {
    const dlat: f64 = lat1 - lat2;
    const dlon: f64 = lon1 - lon2;
    const a: f64 = math.pow(f64, math.sin(dlat / 2), 2) + math.cos(lat1) * math.cos(lat2) * math.pow(f64, math.sin(dlon / 2), 2);
    const c: f64 = 2 * math.asin(math.sqrt(a));
    return c * earth_r;
}

test distance {
    var p1 = core.Point{ .lat = 49.246223, .lon = 30.101769 };
    var p2 = core.Point{ .lat = 48.888504, .lon = 30.697052 };
    convertToRadians(&p1);
    convertToRadians(&p2);

    const dist = distance(p1.lat, p1.lon, p2.lat, p2.lon);

    try testing.expect(58.84 < dist and dist < 58.85);
}

pub fn avgSpeed(distance_km: Distance.km, time_seconds: u32) Speed.MetersPerHour {
    const kmh = distance_km / (@as(f64, @floatFromInt(time_seconds)) / 3_600);
    return @intFromFloat(kmh * 1_000);
}

test avgSpeed {
    try testing.expect(avgSpeed(30, 3_600 * 2) == 15_000);
    const kmh: f64 = 25.471817514143012;
    const mh: core.MetersPerHour = @intFromFloat(kmh * 1_000);
    std.debug.print("MH = {d}\n", .{mh});
}
