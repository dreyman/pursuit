const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const sqlite = @import("sqlite");
const data = @import("data.zig");
const Pursuit = data.Pursuit;

pub fn setup(db_file: [:0]const u8) !void {
    var db = try sqlite.Db.init(.{
        .mode = .{ .File = db_file },
        .open_flags = .{
            .write = true,
            .create = true,
        },
    });
    defer db.deinit();
    try db.exec(create_bike_table, .{}, .{});
    try db.exec(create_pursuit_table, .{}, .{});
}

const create_bike_table =
    \\ create table bike(
    \\      id integer primary key,
    \\      name text not null
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
    //
    \\     foreign key(bike_id) references bike(id)
    \\ ) strict;
;
