const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const posix = std.posix;
const Allocator = mem.Allocator;

const sqlitelib = @import("sqlite");

const Storage = @import("Storage.zig");
const Database = @import("Database.zig");
const data = @import("data.zig");
const Medium = data.Medium;

pub fn install(alloc: Allocator) !void {
    const db_file_path = try setupStorage(alloc);
    const sqlite = try setupDatabase(db_file_path);
    var database = Database{
        .alloc = alloc,
        .sqlite = sqlite.*,
        .file = db_file_path,
    };
    defer database.destroy();
    // try setupInitialData(&database);
}

fn setupStorage(alloc: Allocator) ![:0]const u8 {
    const home_path = posix.getenv("HOME") orelse
        return Storage.Error.HomeDirNotFound;
    var home = try fs.cwd().openDir(home_path, .{});
    defer home.close();
    try home.makeDir(Storage.storage_dir_name);
    var storage_dir = try home.openDir(Storage.storage_dir_name, .{});
    defer storage_dir.close();
    try storage_dir.makeDir(Storage.temp_dir_name);
    try storage_dir.makeDir(Storage.routes_dir_name);

    const db_file_path = try fs.path.joinZ(
        alloc,
        &.{ home_path, Storage.storage_dir_name, Storage.db_file_name },
    );
    return db_file_path;
}

fn setupDatabase(db_file: [:0]const u8) !*sqlitelib.Db {
    var db = try sqlitelib.Db.init(.{
        .mode = .{ .File = db_file },
        .open_flags = .{
            .write = true,
            .create = true,
        },
    });
    try db.execDynamic(create_medium_table, .{}, .{});
    try db.execDynamic(create_pursuit_table, .{}, .{});
    // try db.execDynamic(create_tag_table, .{}, .{});
    // try db.execDynamic(create_pursuit_tag_table, .{}, .{});
    // try db.execDynamic(create_medium_to_medium_table, .{}, .{});
    // try db.execDynamic(create_pursuit_medium_table, .{}, .{});
    return &db;
}

// fn setupInitialData(db: *Database) !void {
//     for (default.Medium.defaults) |default_medium| {
//         var medium = Medium{
//             .id = default_medium.id,
//             .kind = @tagName(default_medium.kind),
//             .name = default_medium.name,
//             .distance = 0,
//             .time = 0,
//             .created_at = @intCast(std.time.timestamp()),
//             .archived = false,
//         };
//         try db.insertMediumWithId(&medium);
//     }
// }

const create_medium_table =
    \\ create table medium(
    \\      id integer primary key,
    \\      kind text not null,
    \\      name text not null,
    \\      created_at integer not null,
    //
    \\      unique(name)
    \\ ) strict;
;

const create_tag_table =
    \\ create table tag(
    \\      id integer primary key,
    \\      name text not null,
    \\ ) strict;
;

const create_pursuit_tag_table =
    \\ create table pursuit_tag(
    \\      pursuit_id integer not null,
    \\      tag_id integer not null,
    //
    \\      unique(pursuit_id, tag_id),
    \\      foreign key(pursuit_id) references pursuit(id),
    \\      foreign key(tag_id) references tag(id)
    \\ ) strict;
;

// const create_medium_to_medium_table =
//     \\ create table medium_to_medium(
//     \\      parent integer,
//     \\      child integer,
//     \\      foreign key(parent) references medium(id),
//     \\      foreign key(child) references medium(id)
//     \\ ) strict;
// ;

// const create_pursuit_medium_table =
//     \\ create table pursuit_medium(
//     \\      pursuit_id integer not null,
//     \\      medium_id integer not null,
//     //
//     \\      unique(pursuit_id, medium_id),
//     \\      foreign key(pursuit_id) references pursuit(id),
//     \\      foreign key(medium_id) references medium(id)
//     \\ ) strict;
// ;

const create_pursuit_table =
    \\ create table pursuit(
    \\     id integer primary key,
    \\     name text not null,
    \\     description text not null,
    \\     kind integer not null,
    \\     medium_id integer,
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
    \\     size integer not null
    //
    \\ ) strict;
;
