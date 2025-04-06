const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const strava_archive = @import("misc/strava_archive.zig");
const Activity = strava_archive.Activity;

const app = @import("app.zig");
const Database = @import("Database.zig");
const data = @import("data.zig");
const Pursuit = data.Pursuit;
const Medium = data.Medium;
const Storage = @import("Storage.zig");

pub const ImportArchiveOptions = struct {
    save_activities_to_db: bool = false,
};

pub fn importStravaArchive(
    alloc: Allocator,
    storage: *Storage,
    archive_dir: []const u8,
    options: ImportArchiveOptions,
) !void {
    if (options.save_activities_to_db) {
        try createStravaTables(&storage.db.sqlite);
    }
    var activities = try strava_archive.getActivities(alloc, archive_dir);
    defer {
        for (activities.items) |ac| ac.destroy();
        activities.deinit();
    }
    var mediums = ArrayList(Medium).fromOwnedSlice(
        storage.alloc,
        try storage.db.getMediums(),
    );
    defer {
        for (mediums.items) |m| {
            // fixme these cause segfault
            // storage.db.alloc.free(m.kind);
            // storage.db.alloc.free(m.name);
            storage.db.alloc.destroy(&m);
        }
        mediums.deinit();
    }

    const from = 0;
    const to = activities.items.len;
    for (activities.items[from..to]) |ac| {
        if (!mem.eql(u8, ac.kind, "Ride") and !mem.eql(u8, ac.kind, "Run")) {
            std.debug.print("\nskip: {d}\n", .{ac.id});
            continue;
        }
        const pursuit_id = importActivity(alloc, storage, ac, &mediums, archive_dir) catch |err|
            switch (err) {
            else => {
                std.debug.print(
                    "\nFailed to import: err = {s} (activity_id = {d})\n",
                    .{ @errorName(err), ac.id },
                );
                continue;
            },
        };
        if (options.save_activities_to_db) {
            ac.start_time = pursuit_id;
            try insertActivity(&storage.db.sqlite, ac);
        }
        std.debug.print(".", .{});
    }
}

fn importActivity(
    alloc: Allocator,
    storage: *Storage,
    activity: *const Activity,
    mediums: *ArrayList(Medium),
    archive_dir: []const u8,
) !Pursuit.ID {
    const file = try fs.path.join(alloc, &.{ archive_dir, activity.file });
    defer alloc.free(file);
    const kind = activityTypeToPursuitKind(activity.kind);

    const medium = mdm: {
        const name = activity.gear;
        if (name.len == 0) break :mdm null;
        for (mediums.items) |m| {
            if (mem.eql(u8, m.name, name))
                break :mdm m;
        }
        const new = try Medium.createEmpty(
            alloc,
            // fixme this will crash in case of unknown strava activity type
            @tagName(mediumKindFromPursuitKind(kind).?),
            name,
        );
        try storage.db.insertMedium(new);
        try mediums.append(new.*);
        break :mdm new.*;
    };

    const pursuit = Pursuit{
        .id = 0,
        .name = if (activity.name.len > 0) activity.name else "Imported from strava",
        .description = if (activity.description.len > 0) activity.description else "",
        .kind = activityTypeToPursuitKind(activity.kind),
        .medium_id = if (medium != null) medium.?.id else null,
    };
    const pursuit_id = try app.importGpsFile(alloc, storage, file, pursuit);
    return pursuit_id;
}

fn initFromActivity(
    alloc: Allocator,
    ac: *const Activity,
) !*Pursuit {
    const p = try alloc.create(Pursuit);
    p.* = .{
        .alloc = alloc,
        .id = 0,
        .name = try alloc.dupe(u8, ac.name),
        .description = try alloc.dupe(u8, ac.description),
        .kind = activityTypeToPursuitKind(ac.kind),
        .medium_id = null,
    };
    return p;
}

fn activityTypeToPursuitKind(activityType: []const u8) Pursuit.Kind {
    if (mem.eql(u8, activityType, "Ride")) return .cycling;
    if (mem.eql(u8, activityType, "Run")) return .running;
    if (mem.eql(u8, activityType, "Walk")) return .walking;
    return .unknown;
}

fn mediumKindFromPursuitKind(kind: Pursuit.Kind) ?Medium.Kind {
    return switch (kind) {
        .cycling => .bike,
        .walking, .running => .shoes,
        .unknown => null,
    };
}

const sqlitelib = @import("sqlite");

fn createStravaTables(db: *sqlitelib.Db) !void {
    const create_activities_table =
        \\ create table if not exists strava_activity(
        \\      id integer primary key,
        \\      start_time integer not null,
        \\      name text not null,
        \\      kind text not null,
        \\      description text not null,
        \\      gear text not null,
        \\      file text not null,
        \\      elapsed_time integer not null,
        \\      moving_time integer not null,
        \\      distance integer not null,
        \\      max_speed integer not null,
        \\      avg_speed integer not null,
        \\      elevation_gain integer not null,
        \\      elevation_loss integer not null
        \\ ) strict;
    ;
    try db.execDynamic(create_activities_table, .{}, .{});
}

fn insertActivity(db: *sqlitelib.Db, ac: *const Activity) !void {
    const insert = "insert into strava_activity values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    try db.execDynamic(insert, .{}, .{
        ac.id,
        ac.start_time,
        ac.name,
        ac.kind,
        ac.description,
        ac.gear,
        ac.file,
        ac.elapsed_time,
        ac.moving_time,
        ac.distance,
        ac.max_speed,
        ac.avg_speed,
        ac.elevation_gain,
        ac.elevation_loss,
    });
}
