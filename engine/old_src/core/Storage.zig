const Storage = @This();

const std = @import("std");
const fs = std.fs;
const Allocator = std.mem.Allocator;

// alloc: Allocator,
dir: fs.Dir,

pub fn create() Storage {}

// fn getStorageDir() !fs.Dir {
//     var dir = try fs.openDirAbsolute(dir_path, .{});
// }

pub const Entry = struct {
    id: u32,
    original_file: []const u8,
};
