const std = @import("std");
const fs = std.fs;
const mem = std.mem;

const decode = @import("decode.zig").decode;
const util = @import("util.zig");
const fit_activity = @import("activity.zig");

pub fn decodeActivityFromFile(alloc: mem.Allocator, file: fs.File) !fit_activity.Activity {
    const stat = try file.stat();
    const bytes: []u8 = try file.readToEndAlloc(alloc, stat.size);

    const fit = try decode(alloc, bytes);
    const activity = try fit_activity.createActivity(alloc, fit);
    return activity;
}
