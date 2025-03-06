const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const gzip = std.compress.gzip;

pub const Extension = enum {
    fit,
    fitgz,
    gpx,
    gpxgz,
};

fn getExtension(path_to_file: []const u8) ?Extension {
    const name = fs.path.basename(path_to_file);
    if (mem.endsWith(u8, name, ".fit")) return .fit;
    if (mem.endsWith(u8, name, ".fit.gz")) return .fitgz;
    if (mem.endsWith(u8, name, ".gpx")) return .gpx;
    if (mem.endsWith(u8, name, ".gpx.gz")) return .gpxgz;
    return null;
}

test getExtension {
    const t = std.testing;
    const fitgz = getExtension("/temp/gzipped.fit.gz");
    const fit = getExtension("/temp/UNGZIPPED.fit");
    const zig = getExtension("~/code/pursuit/src/temp/main.zig");

    try t.expect(fitgz == .fitgz);
    try t.expect(fit == .fit);
    try t.expect(zig == null);
}

// pub fn gzipped_fit(path_to_file: []const u8) !void {
//     const file = try fs.openFileAbsolute(path_to_file, .{});
//     const reader = file.reader();
//     const ungzipped_file = try fs.createFileAbsolute("/home/ihor/code/pursuit/engine/src/temp/UNGZIPPED.fit", .{});
//     try gzip.decompress(reader, ungzipped_file.writer());
// }
