const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const posix = std.posix;

const fit = @import("../fit/fit.zig");

const wf_dir_name = ".wild-fields";

pub const Error = error{HomeDirNotFound} || posix.MakeDirError;

pub fn create(alloc: mem.Allocator) Error!void {
    const home = posix.getenv("HOME") orelse return Error.HomeDirNotFound;
    const wf_dir = "/" ++ wf_dir_name;
    const absolute_path = alloc.alloc(u8, home.len + wf_dir.len) catch unreachable;
    defer alloc.free(absolute_path);
    @memcpy(absolute_path[0..home.len], home);
    @memcpy(absolute_path[home.len..], wf_dir);
    try fs.makeDirAbsolute(absolute_path);
}

// check if the file type is supported
// copy the file
// parse ...
pub fn addFitActivity(alloc: mem.Allocator, file: fs.File) !void {
    const activity = try fit.decodeActivityFromFile(alloc, file);
    std.debug.print("Activity records len: {d}\n", .{activity.records.items.len});
}
