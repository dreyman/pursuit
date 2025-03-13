const std = @import("std");
const fs = std.fs;
const mem = std.mem;

pub const profile = @import("profile.zig");
pub const protocol = @import("fit_protocol.zig");

pub const Activity = @import("activity.zig").Activity;
pub const Record = profile.Record;

pub const Header = protocol.Header;

pub const decode = @import("decode.zig").decode;
pub const util = @import("util.zig");
pub const Sport = profile.Sport;

pub fn decodeActivityFromFile(
    alloc: mem.Allocator,
    file: fs.File,
) !Activity {
    const stat = try file.stat();
    const bytes: []u8 = try file.readToEndAlloc(alloc, stat.size);
    // todo the max number of records in the file
    // can be estimated by (file size) / (number of bytes in the first record)

    var fit = try decode(alloc, bytes);
    defer fit.deinit();
    return try Activity.create(alloc, fit);
}
