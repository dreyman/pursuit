const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const posix = std.posix;
const json = std.json;
const gzip = std.compress.gzip;
const assert = std.debug.assert;

const fit = @import("fit/fit.zig");
const fit_protocol = @import("fit/fit_protocol.zig");
const core = @import("core.zig");

const wf_dir_name = ".wild-fields";

pub const Error = error{HomeDirNotFound} || posix.MakeDirError;

pub fn create(alloc: mem.Allocator) Error!void {
    const path = try storageDirPath(alloc);
    defer alloc.free(path);
    try fs.makeDirAbsolute(path);
}

pub fn addEntry(
    allocator: mem.Allocator,
    original_file_path: []const u8,
    route: core.Route,
    stats: core.Stats,
) !void {
    const entry_dir_path = try getEntryDirPath(allocator, route.time[0]);
    defer allocator.free(entry_dir_path);
    try fs.makeDirAbsolute(entry_dir_path);
    errdefer fs.deleteDirAbsolute(entry_dir_path) catch unreachable; // fixme

    const original_copy_path = try std.fmt.allocPrint(
        allocator,
        "{s}/original.fit", // fixme mb it's better to preserve original file name
        .{entry_dir_path},
    );
    defer allocator.free(original_copy_path);
    try fs.copyFileAbsolute(original_file_path, original_copy_path, .{});
    errdefer fs.deleteFileAbsolute(original_copy_path) catch unreachable; // fixme

    const track_file_path = try std.fmt.allocPrint(allocator, "{s}/track", .{entry_dir_path});
    defer allocator.free(track_file_path);
    const route_file_path = try std.fmt.allocPrint(allocator, "{s}/route", .{entry_dir_path});
    defer allocator.free(route_file_path);
    const stats_file_path = try std.fmt.allocPrint(allocator, "{s}/stats.json", .{entry_dir_path});
    defer allocator.free(stats_file_path);

    try createRouteFile(track_file_path, route, false);
    try createRouteFile(route_file_path, route, true);
    try createStatsFile(stats_file_path, stats);
}

fn createRouteFile(
    file_path: []const u8,
    route: core.Route,
    include_time: bool,
) !void {
    const file = try fs.createFileAbsolute(file_path, .{});
    defer file.close();
    errdefer fs.deleteFileAbsolute(file_path) catch unreachable; // fixme

    const writer = file.writer();
    try writer.writeInt(u32, @intCast(route.len()), .big);
    for (0..route.len()) |i| {
        try writer.writeAll(&mem.toBytes(route.lat[i]));
        try writer.writeAll(&mem.toBytes(route.lon[i]));
        if (include_time) {
            try writer.writeAll(&mem.toBytes(route.time[i]));
        }
        // try writer.writeInt(u32, @as(u32, @bitCast(latlon.lat)), .big);
        // try writer.writeInt(u32, @as(u32, @bitCast(latlon.lon)), .big);
    }
}

fn createStatsFile(
    file_path: []const u8,
    stats: core.Stats,
) !void {
    const file = try fs.createFileAbsolute(file_path, .{});
    defer file.close();
    errdefer fs.deleteFileAbsolute(file_path) catch unreachable; // fixme

    const writer = file.writer();
    try std.json.stringify(stats, .{ .whitespace = .indent_4 }, writer);
}

pub fn ungzip(a: mem.Allocator, file_path: []const u8) !fs.File {
    const name = fs.path.basename(file_path);
    assert(mem.endsWith(u8, name, ".gz"));
    const ungzipped_file_name = name[0 .. name.len - ".gz".len];
    const ungzipped_file = try createTempFile(
        a,
        ungzipped_file_name,
        .{ .read = true },
    );
    const file = try fs.openFileAbsolute(file_path, .{});
    defer file.close();

    try gzip.decompress(file.reader(), ungzipped_file.writer());
    try ungzipped_file.seekTo(0);
    return ungzipped_file;
}

pub fn createTempFile(
    alloc: mem.Allocator,
    name: []const u8,
    flags: fs.File.CreateFlags,
) !fs.File {
    const home_path = posix.getenv("HOME") orelse return Error.HomeDirNotFound;
    const path = std.fmt.allocPrint(
        alloc,
        "{s}/{s}/temp/{s}",
        .{ home_path, wf_dir_name, name },
    ) catch unreachable;
    return try fs.createFileAbsolute(path, flags);
}

pub fn deleteTempFile(
    alloc: mem.Allocator,
    name: []const u8,
) !void {
    const home_path = posix.getenv("HOME") orelse return Error.HomeDirNotFound;
    const path = std.fmt.allocPrint(alloc, "{s}/{s}/temp/{s}", .{
        home_path,
        wf_dir_name,
        name,
    }) catch unreachable;
    return try fs.deleteFileAbsolute(path);
}

fn storageDirPath(alloc: mem.Allocator) ![]const u8 {
    const home_path = posix.getenv("HOME") orelse return Error.HomeDirNotFound;
    return std.fmt.allocPrint(alloc, "{s}/{s}", .{ home_path, wf_dir_name }) catch unreachable;
}

pub fn tempDirPath(alloc: mem.Allocator) ![]const u8 {
    const home_path = posix.getenv("HOME") orelse return Error.HomeDirNotFound;
    return std.fmt.allocPrint(alloc, "{s}/{s}/temp", .{ home_path, wf_dir_name }) catch unreachable;
}

pub fn tempFilePath(alloc: mem.Allocator, filename: []const u8) ![]const u8 {
    const home_path = posix.getenv("HOME") orelse return Error.HomeDirNotFound;
    return std.fmt.allocPrint(alloc, "{s}/{s}/temp/{s}", .{ home_path, wf_dir_name, filename }) catch unreachable;
}

fn getEntryDirPath(a: mem.Allocator, id: u32) ![]const u8 {
    const storage = try storageDirPath(a);
    defer a.free(storage);
    return std.fmt.allocPrint(
        a,
        "{s}/{d}",
        .{ storage, id },
    ) catch unreachable;
}
