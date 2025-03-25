const Storage = @This();

const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const posix = std.posix;
const Allocator = mem.Allocator;

const Database = @import("Database.zig");
const GpsFile = @import("GpsFile.zig");
const data = @import("data.zig");
const Pursuit = data.Pursuit;

const storage_dir_name = ".pursuit";
const db_file_name = "pursuit.db";
const temp_dir_name = "temp";
const max_id_len = maxLen(u32);

dir: fs.Dir,
db: *Database,
alloc: Allocator,

pub const Error = error{HomeDirNotFound};

pub fn create(
    alloc: Allocator,
) !*Storage {
    const home_path = posix.getenv("HOME") orelse
        return Error.HomeDirNotFound;
    const path = try fs.path.join(alloc, &.{ home_path, storage_dir_name });
    defer alloc.free(path);
    const storage = try alloc.create(Storage);
    var dir = try fs.cwd().openDir(path, .{});
    errdefer dir.close();
    var db = try Database.create(alloc, try dbFilePath(alloc));
    errdefer db.destroy();
    storage.* = .{
        .alloc = alloc,
        .db = db,
        .dir = dir,
    };
    errdefer storage.destroy();
    return storage;
}

pub fn destroy(storage: *Storage) void {
    storage.dir.close();
    storage.db.destroy();
    storage.alloc.destroy(storage);
}

pub fn setup(alloc: Allocator) !void {
    const home_path = posix.getenv("HOME") orelse
        return Error.HomeDirNotFound;
    var home = try fs.cwd().openDir(home_path, .{});
    defer home.close();
    try home.makeDir(storage_dir_name);
    var storage_dir = try home.openDir(storage_dir_name, .{});
    defer storage_dir.close();
    try storage_dir.makeDir(temp_dir_name);

    const db_file_path = try fs.path.joinZ(
        alloc,
        &.{ home_path, storage_dir_name, db_file_name },
    );
    defer alloc.free(db_file_path);
    try Database.setup(db_file_path);
}

pub fn saveEntry(
    storage: *Storage,
    original_file: []const u8,
    entry: *Pursuit,
    gps_file: *const GpsFile,
) !void {
    const id = gps_file.stats.start_time;
    // create entry dir
    var buf: [max_id_len]u8 = undefined;
    const entry_dir_name = try std.fmt.bufPrint(&buf, "{}", .{id});
    try storage.dir.makeDir(entry_dir_name);
    const entry_dir = try storage.dir.openDir(entry_dir_name, .{});
    // copy original file
    const copy_name = try originalFileName(storage.alloc, original_file);
    defer storage.alloc.free(copy_name);
    try fs.cwd().copyFile(original_file, entry_dir, copy_name, .{});
    // save stats.json file
    var stats_file = try entry_dir.createFile("stats.json", .{});
    defer stats_file.close();
    try std.json.stringify(
        gps_file.stats,
        .{ .whitespace = .indent_4 },
        stats_file.writer(),
    );
    // save track file
    var track_file = try entry_dir.createFile("track", .{});
    defer track_file.close();
    const trackwriter = track_file.writer();
    for (0..gps_file.route.len()) |i| {
        try trackwriter.writeAll(&mem.toBytes(gps_file.route.lat[i]));
        try trackwriter.writeAll(&mem.toBytes(gps_file.route.lon[i]));
    }
    // save route file
    var route_file = try entry_dir.createFile("route", .{});
    defer route_file.close();
    const routewriter = route_file.writer();
    for (0..gps_file.route.len()) |i| {
        try routewriter.writeAll(&mem.toBytes(gps_file.route.lat[i]));
        try routewriter.writeAll(&mem.toBytes(gps_file.route.lon[i]));
        try routewriter.writeAll(&mem.toBytes(gps_file.route.time[i]));
    }
    // save to db
    const db_file = try dbFilePath(storage.alloc);
    defer storage.alloc.free(db_file);
    try storage.db.saveEntry(id, entry, &gps_file.stats);
    entry.id = id;
}

pub fn createTempFile(storage: *const Storage, filename: []const u8) !fs.File {
    var temp_dir = try storage.dir.openDir(temp_dir_name, .{});
    defer temp_dir.close();
    return try temp_dir.createFile(filename, .{ .read = true });
}

pub fn deleteTempFile(storage: *const Storage, filename: []const u8) !void {
    var temp_dir = try storage.dir.openDir(temp_dir_name, .{});
    defer temp_dir.close();
    return try temp_dir.deleteFile(filename);
}

fn originalFileName(alloc: Allocator, original_file_path: []const u8) ![]u8 {
    const original_name = fs.path.basename(original_file_path);
    const prefix = "original_";
    var result = try alloc.alloc(u8, prefix.len + original_name.len);
    @memcpy(result[0..prefix.len], prefix);
    @memcpy(result[prefix.len..], original_name);
    return result;
}

fn dbFilePath(alloc: Allocator) ![:0]const u8 {
    const home_path = posix.getenv("HOME") orelse
        return Error.HomeDirNotFound;
    return try fs.path.joinZ(
        alloc,
        &.{ home_path, storage_dir_name, db_file_name },
    );
}

fn maxLen(T: type) usize {
    const max = std.math.maxInt(T);
    var buf: [100]u8 = undefined;
    const res = std.fmt.bufPrint(&buf, "{}", .{max}) catch @compileError("asdadas");
    return res.len;
}
