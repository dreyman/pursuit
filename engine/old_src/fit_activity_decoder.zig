const std = @import("std");
const testing = std.testing;

const core = @import("core.zig");
const fit = @import("fit/fit.zig");

pub const Error = error{
    InvalidFitData,
    InvalidFitHeader,
    MissingFileIDDefinition,
    InvalidArchitectureValue,
};

// pub fn decodeActivity(fit_bytes: []const u8) !?core.Route {
//     if (fit_bytes.len < fit.protocol.header_len_min)
//         return Error.InvalidFitData;
//     const header_size = fit_bytes[0];
//     if (header_size != fit.protocol.header_len_min and header_size != fit.protocol.header_len_max)
//         return Error.InvalidFitHeader;
//     const header = fit.Header{ .bytes = fit_bytes[0..header_size] };
//     if (fit_bytes.len < header.size() + header.dataSize()) return Error.InvalidFitData;

//     var pos: usize = header_size;
//     var size: usize = undefined;
//     const header = fit.Message.Header{ .byte = fit_bytes[pos] };
//     pos += 1;
//     if (header.messageType() != .definition)
//         return Error.MissingFileIDDefinition;
//     const arch = bytes[1];
//     if (arch > 1) return Error.InvalidArchitectureValue;
//     const endianess: std.builtin.Endian = if (arch == 0) .little else .big;
//     const global_id = std.mem.readVarInt(u16, bytes[2..4], endianess);

//     while (pos < fit_bytes.len - 2) {
//         const header: fit.Message.Header = .{ .byte = fit_bytes[pos] };
//         pos += 1;
//     }

//     return null;
// }

// test "decodeActivity: error" {
//     try testing.expectError(Error.InvalidFitData, decodeActivity(&[_]u8{ 0, 1, 2, 3 }));
//     try testing.expectError(Error.InvalidFitHeader, decodeActivity(&[_]u8{1} ** 14));
// }

// fn decodeFileID(fit_bytes: []const u8) void {}
