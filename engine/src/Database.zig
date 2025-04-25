const Database = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const sqlitelib = @import("sqlite");

const Stats = @import("Stats.zig");
const data = @import("data.zig");
const Pursuit = data.Pursuit;
const Medium = data.Medium;

file: [:0]const u8,
sqlite: sqlitelib.Db,
alloc: Allocator,

pub fn create(alloc: Allocator, dbfile: [:0]const u8) !*Database {
    const database = try alloc.create(Database);
    database.* = .{
        .file = dbfile,
        .sqlite = try sqlitelib.Db.init(.{
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
    database.sqlite.deinit();
    database.alloc.destroy(database);
}

pub fn savePursuit(
    database: *Database,
    id: Pursuit.ID,
    p: Pursuit,
    s: Stats,
) !void {
    try database.sqlite.execDynamic(
        \\ insert into pursuit(id, name, description, kind, medium_id,
        \\ start_time, finish_time, start_lat, start_lon, finish_lat, finish_lon,
        \\ distance, total_time, moving_time, stops_count, stops_duration, untracked_distance,
        \\ avg_speed, avg_travel_speed, westernmost_lat, westernmost_lon, northernmost_lat,
        \\ northernmost_lon, easternmost_lat, easternmost_lon, southernmost_lat, southernmost_lon, size)
        \\ values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    , .{}, .{
        id,
        p.name,
        p.description,
        @intFromEnum(p.kind),
        p.medium_id,
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
}

pub fn updateStats(
    database: *Database,
    id: Pursuit.ID,
    s: Stats,
) !void {
    try database.sqlite.execDynamic(
        \\ UPDATE pursuit SET
        \\ start_time = ?,
        \\ finish_time = ?,
        \\ start_lat = ?,
        \\ start_lon = ?,
        \\ finish_lat = ?,
        \\ finish_lon = ?,
        \\ distance = ?,
        \\ total_time = ?,
        \\ moving_time = ?,
        \\ stops_count = ?,
        \\ stops_duration = ?,
        \\ untracked_distance = ?,
        \\ avg_speed = ?,
        \\ avg_travel_speed = ?,
        \\ westernmost_lat = ?,
        \\ westernmost_lon = ?,
        \\ northernmost_lat = ?,
        \\ northernmost_lon = ?,
        \\ easternmost_lat = ?,
        \\ easternmost_lon = ?,
        \\ southernmost_lat = ?,
        \\ southernmost_lon = ?,
        \\ size = ?
        \\ WHERE id = ?
    , .{}, .{
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
        id,
    });
}

pub fn findByTimestamp(database: *Database, timestamp: u32) !?Pursuit.ID {
    const sql = "select id from pursuit where start_time < ? and finish_time > ? limit 1";
    var stmt = try database.sqlite.prepareDynamic(sql);
    defer stmt.deinit();
    const id = try stmt.one(Pursuit.ID, .{}, .{ timestamp, timestamp });
    return id;
}

pub fn setMedium(
    database: *Database,
    pursuit_id: Pursuit.ID,
    medium_id: Medium.ID,
) !void {
    try database.sqlite.execDynamic(
        "update pursuit set medium_id = ? where id = ?",
        .{},
        .{ medium_id, pursuit_id },
    );
}

pub fn insertMedium(database: *Database, m: *Medium) !void {
    try database.sqlite.execDynamic(
        "insert into medium(kind, name, created_at) values (?, ?, ?)",
        .{},
        .{ m.kind, m.name, m.created_at },
    );
    m.id = @intCast(database.sqlite.getLastInsertRowID());
}

// pub fn insertMediumWithId(database: *Database, m: *Medium) !void {
//     try database.db.execDynamic(
//         \\insert into medium(id, kind, name, distance, time, created_at, archived)
//         \\values (?, ?, ?, ?, ?, ?, ?)
//     ,
//         .{},
//         .{ m.id, m.kind, m.name, m.distance, m.time, m.created_at, m.archived },
//     );
// }

pub fn updateMedium(database: *Database, m: *const Medium) !void {
    try database.sqlite.execDynamic(
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
    var stmt = try database.sqlite.prepareDynamic(q);
    defer stmt.deinit();
    const ms = try stmt.all(Medium, database.alloc, .{}, .{});
    return ms;
}
