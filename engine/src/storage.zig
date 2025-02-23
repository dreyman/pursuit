const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const posix = std.posix;

const fit = @import("fit/fit.zig");
const Activity = @import("core/activity.zig").Activity;

const wf_dir_name = ".wild-fields";

pub const Error = error{HomeDirNotFound} || posix.MakeDirError;

pub const Entry = struct {
    activity: Activity,
    file: []const u8,
};

pub fn create(alloc: mem.Allocator) Error!void {
    const path = try getStorageDirPath(alloc);
    defer alloc.free(path);
    try fs.makeDirAbsolute(path);
}

// copy the file
// parse ...
pub fn addActivity(alloc: mem.Allocator, activity: Activity, file: []const u8) !void {
    const dir_path = try getActivityDirPath(alloc, activity);
    defer alloc.free(dir_path);
    try fs.makeDirAbsolute(dir_path);
    const acitity_file_path = std.fmt.allocPrint(
        alloc,
        "{s}/{d}.fit",
        .{ dir_path, activity.timestamp },
    ) catch unreachable;
    defer alloc.free(acitity_file_path);
    try fs.copyFileAbsolute(file, acitity_file_path, .{});
}

fn getStorageDirPath(alloc: mem.Allocator) ![]const u8 {
    const home_path = posix.getenv("HOME") orelse return Error.HomeDirNotFound;
    return std.fmt.allocPrint(alloc, "{s}/{s}", .{ home_path, wf_dir_name }) catch unreachable;
}

fn getActivityDirPath(alloc: mem.Allocator, activity: Activity) ![]const u8 {
    const storage = try getStorageDirPath(alloc);
    defer alloc.free(storage);
    return std.fmt.allocPrint(alloc, "{s}/{d}", .{ storage, activity.timestamp }) catch unreachable;
}
