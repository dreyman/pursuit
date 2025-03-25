const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const archive = @import("misc/strava_archive.zig");
const Activity = archive.Activity;

const Database = @import("Database.zig");
const GpsFile = @import("GpsFile.zig");
const data = @import("data.zig");
const Pursuit = data.Pursuit;
const Bike = data.Bike;
const Storage = @import("Storage.zig");

pub fn importStravaArchive(alloc: Allocator, export_dir: []const u8) !void {
    var activities = try archive.processStravaArchive(alloc, export_dir);
    defer {
        for (activities.items) |ac| ac.destroy();
        activities.deinit();
    }
    var storage = try Storage.create(alloc);
    const existing_bikes = try storage.db.getBikes();
    defer {
        for (existing_bikes) |b| alloc.destroy(&b);
        storage.alloc.free(existing_bikes);
        storage.destroy();
    }
    var bikes = ArrayList(*Bike).init(alloc);
    for (existing_bikes) |b| {
        var bike = b;
        try bikes.append(&bike);
    }
    defer {
        for (bikes.items[existing_bikes.len..]) |b| alloc.destroy(b);
        bikes.deinit();
    }

    for (activities.items) |ac| {
        importActivity(alloc, storage, ac, &bikes, export_dir) catch |err| switch (err) {
            else => {
                std.debug.print("\nFailed to import: err = {s} (activity_id = {d})\n", .{
                    @errorName(err),
                    ac.id,
                });
                continue;
            },
        };
        std.debug.print(".", .{});
    }
    for (bikes.items) |b| try storage.db.updateBike(b);
}

fn importActivity(
    alloc: Allocator,
    storage: *Storage,
    activity: *const Activity,
    bikes: *ArrayList(*Bike),
    export_dir: []const u8,
) !void {
    const file = try fs.path.join(alloc, &.{ export_dir, activity.file });
    defer alloc.free(file);
    const bike_name = activity.gear;
    var bike = try getOrCreateBike(storage.db, bike_name, bikes.items);
    try bikes.append(bike);

    const prst = try initEntry(alloc, activity, bike.id);
    const gps_file = try GpsFile.create(alloc, storage, file);
    defer alloc.destroy(gps_file);
    bike.time += gps_file.stats.moving_time;
    bike.distance += gps_file.stats.distance;

    try storage.saveEntry(file, prst, gps_file);
}

fn initEntry(alloc: Allocator, ac: *const Activity, bike_id: Bike.ID) !*Pursuit {
    const p = try alloc.create(Pursuit);
    p.* = .{
        .alloc = alloc,
        .id = 0,
        .bike_id = bike_id,
        .name = try alloc.dupe(u8, ac.name),
        .description = try alloc.dupe(u8, ac.description),
        .kind = activityTypeToKind(ac.kind),
    };
    return p;
}

fn activityTypeToKind(activityType: []const u8) Pursuit.Kind {
    if (mem.eql(u8, activityType, "Ride")) return .cycling;
    if (mem.eql(u8, activityType, "Run")) return .running;
    return .unknown;
}

fn getOrCreateBike(
    db: *Database,
    name: []const u8,
    bikes: []*Bike,
) !*Bike {
    for (bikes) |b| {
        if (mem.eql(u8, b.name, name) or (name.len == 0 and mem.eql(u8, b.name, "Unknown")))
            return b;
    }
    return try db.createBikeWithName(name);
}
