const std = @import("std");
const fs = std.fs;
const mem = std.mem;

const profile = @import("profile.zig");

pub const Activity = @import("activity.zig").Activity;

pub const decode = @import("decode.zig").decode;
pub const util = @import("util.zig");
pub const Sport = profile.Sport;

pub fn decodeActivityFromFile(
    alloc: mem.Allocator,
    file: fs.File,
) !Activity {
    const stat = try file.stat();
    const bytes: []u8 = try file.readToEndAlloc(alloc, stat.size);

    const fit = try decode(alloc, bytes);
    const a = try Activity.create(alloc, fit);
    return a;
}
