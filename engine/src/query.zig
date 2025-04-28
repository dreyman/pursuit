const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const geo = @import("geo.zig");
const calc = @import("calc.zig");
const Storage = @import("Storage.zig");
const data = @import("data.zig");
const Pursuit = data.Pursuit;

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

pub const LocationFlyby = extern struct {
    pursuit_id: Pursuit.ID,
    lat: f32,
    lon: f32,
    timestamp: u32,
    distance: geo.Distance.Km,
};

pub fn findLocationFlybysJson(
    gpa: Allocator,
    storage: *Storage,
    point: geo.Point,
    max_distance: geo.Distance.Km,
    max_count: usize,
    time_gap: u32,
) !ArrayList(u8) {
    const ids = try storage.db.findContainingPoint(point);
    defer storage.db.alloc.free(ids);
    var flybys = try ArrayList(*LocationFlyby).initCapacity(gpa, max_count);
    defer {
        for (flybys.items) |p| gpa.destroy(p);
        flybys.deinit();
    }

    for (ids) |route_id| {
        if (flybys.items.len >= max_count)
            break;
        try routeClosestPoints(
            gpa,
            storage,
            route_id,
            point,
            &flybys,
            max_distance,
            time_gap,
        );
    }
    var json_str = try ArrayList(u8).initCapacity(gpa, 20_000);
    try std.json.stringify(
        flybys.items,
        .{ .whitespace = .indent_4 },
        json_str.writer(),
    );
    return json_str;
}

pub fn routeClosestPoints(
    gpa: Allocator,
    storage: *Storage,
    route_id: Pursuit.ID,
    point: geo.Point,
    list: *ArrayList(*LocationFlyby),
    max_distance: geo.Distance.Km,
    time_gap: u32,
) !void {
    var route = try storage.getRoute(route_id);
    defer route.deinit();
    for (0..route.len()) |i| {
        const distance = calc.distanceDegrees(
            route.lat[i],
            route.lon[i],
            point.lat,
            point.lon,
        );
        if (distance < max_distance) {
            var replace = false;
            const flyby = rp: {
                if (list.items.len > 0) {
                    const last = list.items[list.items.len - 1];
                    if (distance < last.distance) {
                        if (route.time[i] - last.timestamp <= time_gap) {
                            replace = true;
                            break :rp last;
                        } else {
                            break :rp try gpa.create(LocationFlyby);
                        }
                    } else {
                        if (route.time[i] - last.timestamp <= time_gap) {
                            continue;
                        } else {
                            break :rp try gpa.create(LocationFlyby);
                        }
                    }
                }
                break :rp try gpa.create(LocationFlyby);
            };
            flyby.* = .{
                .pursuit_id = route_id,
                .lat = route.lat[i],
                .lon = route.lon[i],
                .timestamp = route.time[i],
                .distance = distance,
            };
            if (!replace) try list.append(flyby);
        }
    }
}
