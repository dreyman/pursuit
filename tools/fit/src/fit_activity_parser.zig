const std = @import("std");
const fs = @import("fs");
const assert = std.debug.assert;

const fit_header_endianess = std.builtin.Endian.little;

pub const Entry = struct {
    lat: f64,
    lon: f64,
    timestamp: u64,
};

pub fn parseFitActivity(fit_data: []u8) !std.ArrayList(Entry) {
    const header_size = fit_data[0];
    assert(header_size == 12 or header_size == 14); // fixme proper error
    // const data_size = parseFitHeader(fit_data[0..header_size]);
}

fn parseFitHeader(bytes: []u8) u32 {
    assert(bytes.len == 12 or bytes.len == 14);
    return std.mem.readVarInt(u32, bytes[4..8], fit_header_endianess);
}

test "parses fit activity" {
    const t = std.testing;

    try t.expect(true);
}
