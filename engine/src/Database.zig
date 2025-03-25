const Database = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const sqlite = @import("sqlite");
const data = @import("data.zig");
const Pursuit = data.Pursuit;
const Stats = data.Stats;
const Bike = data.Bike;

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

pub fn saveEntry(
    database: *Database,
    id: u32,
    p: *const Pursuit,
    s: *const Stats,
) !void {
    var db = database.db;
    try db.execDynamic(
        \\ insert into pursuit(id, name, description, kind, bike_id,
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
        p.bike_id,
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

pub fn setup(db_file: [:0]const u8) !void {
    var db = try sqlite.Db.init(.{
        .mode = .{ .File = db_file },
        .open_flags = .{
            .write = true,
            .create = true,
        },
    });
    defer db.deinit();
    try db.execDynamic(create_bike_table, .{}, .{});
    try db.execDynamic(create_pursuit_table, .{}, .{});
    try createBike(&db, &.{
        .id = 0,
        .name = "Unknown",
        .distance = 0,
        .time = 0,
        .created_at = @intCast(std.time.timestamp()),
        .archived = false,
    });
}

pub fn createBike(db: *sqlite.Db, bike: *const Bike) !void {
    try db.execDynamic(
        "insert into bike(name, distance, time, created_at, archived) values (?, ?, ?, ?, ?)",
        .{},
        .{ bike.name, bike.distance, bike.time, bike.created_at, bike.archived },
    );
}

pub fn updateBike(database: *Database, bike: *const Bike) !void {
    try database.db.execDynamic(
        \\ update bike
        \\ set name = ?, distance = ?, time = ?, archived = ?
        \\ where id = ?
    ,
        .{},
        .{ bike.name, bike.distance, bike.time, bike.archived, bike.id },
    );
}

pub fn createBikeWithName(database: *Database, name: []const u8) !*Bike {
    const bike = try database.alloc.create(Bike);
    bike.* = .{
        .id = 0,
        .name = name,
        .distance = 0,
        .time = 0,
        .created_at = @intCast(std.time.timestamp()),
        .archived = false,
    };
    try createBike(&database.db, bike);
    bike.id = @intCast(database.db.getLastInsertRowID());
    return bike;
}

pub fn getBikes(database: *Database) ![]Bike {
    const q = "select * from bike";
    var stmt = try database.db.prepareDynamic(q);
    defer stmt.deinit();
    const bikes = try stmt.all(Bike, database.alloc, .{}, .{});
    return bikes;
}

const create_bike_table =
    \\ create table bike(
    \\      id integer primary key,
    \\      name text not null,
    \\      distance integer not null,
    \\      time integer not null,
    \\      created_at integer not null,
    \\      archived integer not null
    \\ ) strict;
;

const create_pursuit_table =
    \\ create table pursuit(
    \\     id integer primary key,
    \\     name text not null,
    \\     description text not null,
    \\     kind integer not null,
    \\     bike_id integer not null,
    // readonly stats:
    \\     start_time integer not null,
    \\     finish_time integer not null,
    \\     start_lat real not null,
    \\     start_lon real not null,
    \\     finish_lat real not null,
    \\     finish_lon real not null,
    \\     distance integer not null,
    \\     total_time integer not null,
    \\     moving_time integer not null,
    \\     stops_count integer not null,
    \\     stops_duration integer not null,
    \\     untracked_distance integer not null,
    \\     avg_speed integer not null,
    \\     avg_travel_speed integer not null,
    \\     westernmost_lat real not null,
    \\     westernmost_lon real not null,
    \\     northernmost_lat real not null,
    \\     northernmost_lon real not null,
    \\     easternmost_lat real not null,
    \\     easternmost_lon real not null,
    \\     southernmost_lat real not null,
    \\     southernmost_lon real not null,
    \\     size integer not null,
    //
    \\     foreign key(bike_id) references bike(id)
    \\ ) strict;
;
