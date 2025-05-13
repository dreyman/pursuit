const std = @import("std");
const Allocator = std.mem.Allocator;

const Storage = @import("../Storage.zig");
const geo = @import("../geo.zig");
const calc = @import("../calc.zig");
const data = @import("../data.zig");
const Route = data.Route;

pub const LocationForTimestamp = struct {
    lat: geo.Latitude,
    lon: geo.Longitude,
    precision: Precision,
    stopped_at: ?geo.Point,
    resumed_at: ?geo.Point,
    distance: ?geo.Distance.Km,

    pub const Precision = enum { exact, midpoint };
};

pub fn findLocationForTimestamp(
    gpa: Allocator,
    storage: *Storage,
    timestamp: u32,
) !?*LocationForTimestamp {
    const pursuit_id = try storage.db.findByTimestamp(timestamp) orelse
        return null;
    var route = try storage.getRoute(pursuit_id);
    defer route.deinit();

    const result = try gpa.create(LocationForTimestamp);
    errdefer gpa.destroy(result);
    // fixme use binary search
    for (0..route.time.len) |i| {
        if (route.time[i] == timestamp) {
            result.* = .{
                .lat = route.lat[i],
                .lon = route.lon[i],
                .precision = .exact,
                .stopped_at = null,
                .resumed_at = null,
                .distance = null,
            };
            return result;
        }
        if (route.time[i] > timestamp and i > 0 and route.time[i - 1] < timestamp) {
            result.* = .{
                .lat = undefined,
                .lon = undefined,
                .precision = .midpoint,
                .stopped_at = .{
                    .lat = route.lat[i - 1],
                    .lon = route.lon[i - 1],
                },
                .resumed_at = .{
                    .lat = route.lat[i],
                    .lon = route.lon[i],
                },
                .distance = undefined,
            };
            const midpoint = calc.midpoint(result.*.stopped_at.?, result.*.resumed_at.?);
            result.*.lat = midpoint.lat;
            result.*.lon = midpoint.lon;
            result.*.distance = calc.distanceDegrees(
                result.*.stopped_at.?.lat,
                result.*.stopped_at.?.lon,
                result.*.resumed_at.?.lat,
                result.*.resumed_at.?.lon,
            );
            return result;
        }
    }
    return null;
}
