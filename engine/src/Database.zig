const Database = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const sqlite = @import("sqlite");

const default = @import("default_data.zig");
const data = @import("data.zig");
const Pursuit = data.Pursuit;
const Stats = data.Stats;
const Medium = data.Medium;

file: [:0]const u8,
db: sqlite.Db,
alloc: Allocator,

pub fn create(alloc: Allocator, dbfile: [:0]const u8) !*Database {
    const database = try alloc.create(Database);
    database.* = .{
        .file = dbfile,
        .db = try sqlite.Db.init(.{
            .mode = .{ .File = dbfile },
            .open_flags = .{
                .write = true,
                .create = false,
            },
        }),
        .alloc = alloc,
    };
    return database;
}

pub fn destroy(database: *Database) void {
    database.alloc.free(database.file);
    database.db.deinit();
    database.alloc.destroy(database);
}

pub fn savePursuit(
    database: *Database,
    id: u32,
    p: *const Pursuit,
    s: *const Stats,
    medium_id: ?Medium.ID,
) !void {
    var db = database.db;
    try db.execDynamic(
        \\ insert into pursuit(id, name, description, kind,
        \\ start_time, finish_time, start_lat, start_lon, finish_lat, finish_lon,
        \\ distance, total_time, moving_time, stops_count, stops_duration, untracked_distance,
        \\ avg_speed, avg_travel_speed, westernmost_lat, westernmost_lon, northernmost_lat,
        \\ northernmost_lon, easternmost_lat, easternmost_lon, southernmost_lat, southernmost_lon, size)
        \\ values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    , .{}, .{
        id,
        p.name,
        p.description,
        @intFromEnum(p.kind),
        s.start_time,
        s.finish_time,
        s.start.lat,
        s.start.lon,
        s.finish.lat,
        s.finish.lon,
        s.distance,
        s.total_time,
        s.moving_time,
        s.stops_count,
        s.stops_duration,
        s.untracked_distance,
        s.avg_speed,
        s.avg_travel_speed,
        s.westernmost.lat,
        s.westernmost.lon,
        s.northernmost.lat,
        s.northernmost.lon,
        s.easternmost.lat,
        s.easternmost.lon,
        s.southernmost.lat,
        s.southernmost.lon,
        s.size,
    });
    if (medium_id) |medium| {
        try db.execDynamic("insert into pursuit_medium(pursuit_id, medium_id) values(?, ?)", .{}, .{
            id,
            medium,
        });
        try db.execDynamic(
            \\ update medium
            \\ set distance = distance + ?, time = time + ?
            \\ where id = ?
        , .{}, .{
            s.distance,
            s.moving_time,
            medium,
        });
    }
}

pub fn insertMedium(database: *Database, m: *Medium) !void {
    try database.db.execDynamic(
        \\insert into medium(kind, name, distance, time, created_at, archived)
        \\values (?, ?, ?, ?, ?, ?)
    ,
        .{},
        .{ m.kind, m.name, m.distance, m.time, m.created_at, m.archived },
    );
    m.id = @intCast(database.db.getLastInsertRowID());
}

pub fn insertMediumWithId(database: *Database, m: *Medium) !void {
    try database.db.execDynamic(
        \\insert into medium(id, kind, name, distance, time, created_at, archived)
        \\values (?, ?, ?, ?, ?, ?, ?)
    ,
        .{},
        .{ m.id, m.kind, m.name, m.distance, m.time, m.created_at, m.archived },
    );
}

pub fn updateMedium(database: *Database, m: *const Medium) !void {
    try database.db.execDynamic(
        \\ update medium
        \\ set name = ?, distance = ?, time = ?, archived = ?
        \\ where id = ?
    ,
        .{},
        .{ m.name, m.distance, m.time, m.archived, m.id },
    );
}

pub fn getMediums(database: *Database) ![]Medium {
    const q = "select * from medium";
    var stmt = try database.db.prepareDynamic(q);
    defer stmt.deinit();
    const ms = try stmt.all(Medium, database.alloc, .{}, .{});
    return ms;
}
