const std = @import("std");

const geo = @import("geo.zig");
const Storage = @import("Storage.zig");

pub fn findPointByTimestamp(storage: *Storage, timestamp: u32) !?geo.Point {
    const id = try storage.db.findByTimestamp(timestamp) orelse
        return null;
    var route = try storage.getRoute(id);
    defer route.deinit();
    for (0..route.time.len) |i| {
        if (route.time[i] == timestamp)
            return .{
                .lat = route.lat[i],
                .lon = route.lon[i],
            };
        if (route.time[i] > timestamp and i > 0 and route.time[i - 1] < timestamp) {
            return .{
                .lat = route.lat[i - 1],
                .lon = route.lon[i - 1],
            };
        }
    }
    return null;
}
