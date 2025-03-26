const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const archive = @import("misc/strava_archive.zig");
const Activity = archive.Activity;

const Database = @import("Database.zig");
const GpsFile = @import("GpsFile.zig");
const data = @import("data.zig");
const Pursuit = data.Pursuit;
const Medium = data.Medium;
const Storage = @import("Storage.zig");
const default = @import("default_data.zig");

pub fn importStravaArchive(alloc: Allocator, export_dir: []const u8) !void {
    var activities = try archive.processStravaArchive(alloc, export_dir);
    defer {
        for (activities.items) |ac| ac.destroy();
        activities.deinit();
    }
    var storage = try Storage.create(alloc);
    var mediums = ArrayList(Medium).fromOwnedSlice(storage.alloc, try storage.db.getMediums());
    defer {
        for (mediums.items) |m| storage.alloc.destroy(&m);
        mediums.deinit();
        storage.destroy();
    }

    for (activities.items[150..181]) |ac| {
        importActivity(alloc, storage, ac, &mediums, export_dir) catch |err|
            switch (err) {
            else => {
                std.debug.print(
                    "\nFailed to import: err = {s} (activity_id = {d})\n",
                    .{ @errorName(err), ac.id },
                );
                continue;
            },
        };
        std.debug.print(".", .{});
    }
}

pub const ImportActivityError = error{UnknownActivityType};

fn importActivity(
    alloc: Allocator,
    storage: *Storage,
    activity: *const Activity,
    mediums: *ArrayList(Medium),
    export_dir: []const u8,
) !void {
    const file = try fs.path.join(alloc, &.{ export_dir, activity.file });
    defer alloc.free(file);
    const kind = activityTypeToPursuitKind(activity.kind) orelse
        return ImportActivityError.UnknownActivityType;
    assert(kind != .unknown);

    const prst = try initEntry(alloc, activity);
    const gps_file = try GpsFile.create(alloc, storage, file);
    defer alloc.destroy(gps_file);
    // [create and] update medium
    const medium = mdm: {
        const name = if (activity.gear.len > 0)
            activity.gear
        else
            default.Medium.defaultForPursuitKind(kind).?.name;
        for (mediums.items) |m| {
            if (mem.eql(u8, m.name, name))
                break :mdm m;
        }
        const new = try Medium.createEmpty(
            alloc,
            @tagName(default.Medium.mediumKindFromPursuitKind(kind).?),
            name,
        );
        try storage.db.insertMedium(new);
        try mediums.append(new.*);
        break :mdm new.*;
    };

    try storage.saveEntry(file, prst, gps_file, medium.id);
}

fn initEntry(
    alloc: Allocator,
    ac: *const Activity,
) !*Pursuit {
    const p = try alloc.create(Pursuit);
    p.* = .{
        .alloc = alloc,
        .id = 0,
        .name = try alloc.dupe(u8, ac.name),
        .description = try alloc.dupe(u8, ac.description),
        .kind = activityTypeToPursuitKind(ac.kind) orelse .unknown,
    };
    return p;
}

fn activityTypeToPursuitKind(activityType: []const u8) ?Pursuit.Kind {
    if (mem.eql(u8, activityType, "Ride")) return .cycling;
    if (mem.eql(u8, activityType, "Run")) return .running;
    return null;
}
