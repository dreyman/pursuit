const std = @import("std");

pub fn fileAsBytes(alloc: std.mem.Allocator, file_path: []const u8) ![]u8 {
    const file = try std.fs.openFileAbsolute(file_path, .{});
    defer file.close();

    const stat = try file.stat();
    const buf: []u8 = try file.readToEndAlloc(alloc, stat.size);
    return buf;
}

pub fn semicirclesToDegrees(semicircles: ?i32) ?f32 {
    if (semicircles == null) return null;
    const radians = (@as(f32, @floatFromInt(semicircles.?)) * std.math.pi) / 0x80000000;
    return std.math.radiansToDegrees(radians);
}
