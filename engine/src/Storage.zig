const Storage = @This();

const std = @import("std");
const fs = std.fs;
const gzip = std.compress.gzip;
const mem = std.mem;
const posix = std.posix;
const assert = std.debug.assert;
const Allocator = mem.Allocator;

const Database = @import("Database.zig");
const data = @import("data.zig");
const Pursuit = data.Pursuit;
const Medium = data.Medium;
const Route = data.Route;
const Stats = data.Stats;

pub const storage_dir_name = ".pursuit";
pub const db_file_name = "pursuit.db";
pub const temp_dir_name = "temp";
pub const routes_dir_name = "routes";
const max_id_len = maxLen(Pursuit.ID);

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

pub fn saveEntry(
    storage: *const Storage,
    original_file: []const u8,
    entry: Pursuit,
    route: Route,
    stats: Stats,
) !Pursuit.ID {
    const id = stats.start_time;
    // create entry dir
    var routes_dir = try storage.dir.openDir(routes_dir_name, .{});
    defer routes_dir.close();
    var buf: [max_id_len]u8 = undefined;
    const entry_dir_name = try std.fmt.bufPrint(&buf, "{}", .{id});
    try routes_dir.makeDir(entry_dir_name);
    var entry_dir = try routes_dir.openDir(entry_dir_name, .{});
    defer entry_dir.close();
    // copy original file
    const copy_name = try originalFileName(storage.alloc, original_file);
    defer storage.alloc.free(copy_name);
    try fs.cwd().copyFile(original_file, entry_dir, copy_name, .{});
    // save stats.json file
    var stats_file = try entry_dir.createFile("stats.json", .{});
    defer stats_file.close();
    try std.json.stringify(
        stats,
        .{ .whitespace = .indent_4 },
        stats_file.writer(),
    );
    // save track file
    var track_file = try entry_dir.createFile("track", .{});
    defer track_file.close();
    const trackwriter = track_file.writer();
    for (0..route.len()) |i| {
        try trackwriter.writeAll(&mem.toBytes(route.lat[i]));
        try trackwriter.writeAll(&mem.toBytes(route.lon[i]));
    }
    // save route file
    var route_file = try entry_dir.createFile("route", .{});
    defer route_file.close();
    const routewriter = route_file.writer();
    for (0..route.len()) |i| {
        try routewriter.writeAll(&mem.toBytes(route.lat[i]));
        try routewriter.writeAll(&mem.toBytes(route.lon[i]));
        try routewriter.writeAll(&mem.toBytes(route.time[i]));
    }
    // save to db
    const db_file = try dbFilePath(storage.alloc);
    defer storage.alloc.free(db_file);
    try storage.db.savePursuit(
        id,
        entry,
        stats,
    );
    return id;
}

pub fn ungzip(storage: *const Storage, gzipped_file_path: []const u8) !fs.File {
    const fullname = fs.path.basename(gzipped_file_path);
    const ungzipped_name = fullname[0 .. fullname.len - ".gz".len];
    var ungzipped = try storage.createTempFile(ungzipped_name);
    const gzipped = try fs.cwd().openFile(gzipped_file_path, .{});
    defer gzipped.close();
    try gzip.decompress(gzipped.reader(), ungzipped.writer());
    try ungzipped.seekTo(0);
    return ungzipped;
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
    var buf: [50]u8 = undefined;
    const res = std.fmt.bufPrint(&buf, "{}", .{max}) catch @compileError("buffer too small");
    return res.len;
}
