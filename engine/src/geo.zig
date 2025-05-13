const std = @import("std");
const math = std.math;

pub const Latitude = f32;
pub const Longitude = f32;

pub const Speed = struct {
    pub const MetersPerHour = u21;
};

pub const Distance = struct {
    pub const Km = f64;
    pub const Meters = u32;
};

pub const Point = struct {
    lat: f32,
    lon: f32,

    pub const Unit = enum { degrees, radians };

    pub fn toDegrees(this: *Point) void {
        this.lat = math.radiansToDegrees(this.lat);
        this.lon = math.radiansToDegrees(this.lon);
    }

    pub fn toRadians(this: *Point) void {
        this.lat = math.degreesToRadians(this.lat);
        this.lon = math.degreesToRadians(this.lon);
    }
};
