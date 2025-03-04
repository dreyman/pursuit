const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const posix = std.posix;
const json = std.json;

const fit = @import("fit/fit.zig");
const fit_protocol = @import("fit/fit_protocol.zig");
const core = @import("core.zig");
const geo = @import("geo.zig");

const wf_dir_name = ".wild-fields";

pub const Error = error{HomeDirNotFound} || posix.MakeDirError;

pub fn create(alloc: mem.Allocator) Error!void {
    const path = try getStorageDirPath(alloc);
    defer alloc.free(path);
    try fs.makeDirAbsolute(path);
}

pub fn addEntry(
    allocator: mem.Allocator,
    original_file_path: []const u8,
    route: geo.Route,
) !void {
    const entry_dir_path = try getEntryDirPath(allocator, route.timestamps[0]);
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

    try createRouteFile(track_file_path, route, false);
    try createRouteFile(route_file_path, route, true);
}

fn createRouteFile(
    file_path: []const u8,
    route: geo.Route,
    include_time: bool,
) !void {
    const file = try fs.createFileAbsolute(file_path, .{});
    defer file.close();
    errdefer fs.deleteFileAbsolute(file_path) catch unreachable; // fixme

    const writer = file.writer();
    try writer.writeInt(u32, @intCast(route.points.len), .big);
    for (route.points, 0..) |point, i| {
        try writer.writeAll(&mem.toBytes(point.lat));
        try writer.writeAll(&mem.toBytes(point.lon));
        if (include_time) {
            try writer.writeAll(&mem.toBytes(route.timestamps[i]));
        }
        // try writer.writeInt(u32, @as(u32, @bitCast(latlon.lat)), .big);
        // try writer.writeInt(u32, @as(u32, @bitCast(latlon.lon)), .big);
    }
}

fn getStorageDirPath(alloc: mem.Allocator) ![]const u8 {
    const home_path = posix.getenv("HOME") orelse return Error.HomeDirNotFound;
    return std.fmt.allocPrint(alloc, "{s}/{s}", .{ home_path, wf_dir_name }) catch unreachable;
}

fn getEntryDirPath(a: mem.Allocator, id: u32) ![]const u8 {
    const storage = try getStorageDirPath(a);
    defer a.free(storage);
    return std.fmt.allocPrint(
        a,
        "{s}/{d}",
        .{ storage, id },
    ) catch unreachable;
}
