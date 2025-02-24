const std = @import("std");

pub fn semicirclesToDegrees(semicircles: i32) f32 {
    const radians = (@as(f32, @floatFromInt(semicircles)) * std.math.pi) / 0x80000000;
    return std.math.radiansToDegrees(radians);
}
