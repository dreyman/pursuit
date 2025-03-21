const GpsFile = @This();

const std = @import("std");
const assert = std.debug.assert;
const mem = std.mem;
const fs = std.fs;
const Allocator = mem.Allocator;
const gzip = std.compress.gzip;

const Storage = @import("Storage.zig");
const data = @import("data.zig");
const fitfile = @import("gpsfile/fitfile.zig");
const gpxfile = @import("gpsfile/gpxfile.zig");

route: data.Route,
stats: data.Stats,
kind: data.Pursuit.Kind,

pub const fit_file_size_max = 50_000_000;
pub const gpx_file_size_max = 80_000_000;

pub const Type = enum {
    fit,
    fitgz,
    gpx,
    gpxgz,

    pub fn fromPath(path: []const u8) ?Type {
        if (mem.endsWith(u8, path, ".fit")) return .fit;
        if (mem.endsWith(u8, path, ".fit.gz")) return .fitgz;
        if (mem.endsWith(u8, path, ".gpx")) return .gpx;
        if (mem.endsWith(u8, path, ".gpx.gz")) return .gpxgz;
        return null;
    }
};

pub const Error = error{UnsupportedFileFormat};

pub fn create(
    alloc: Allocator,
    storage: *const Storage,
    file: []const u8,
) !*GpsFile {
    const gpsFileType = Type.fromPath(file) orelse
        return Error.UnsupportedFileFormat;
    switch (gpsFileType) {
        .fit => {
            return try fitfile.decode(
                alloc,
                try readFileContent(alloc, file, gpsFileType),
            );
        },
        .gpx => {
            return try gpxfile.parse(
                alloc,
                try readFileContent(alloc, file, gpsFileType),
            );
        },
        .fitgz, .gpxgz => {
            const fullname = fs.path.basename(file);
            assert(mem.endsWith(u8, fullname, ".gz"));
            const ungzipped_name = fullname[0 .. fullname.len - ".gz".len];
            var ungzipped = try storage.createTempFile(ungzipped_name);
            defer {
                ungzipped.close();
                storage.deleteTempFile(ungzipped_name) catch
                    std.log.info("Failed to delete temp file: {s}", .{ungzipped_name});
            }
            const gzipped = try fs.cwd().openFile(file, .{});
            defer gzipped.close();
            try gzip.decompress(gzipped.reader(), ungzipped.writer());
            try ungzipped.seekTo(0);

            if (gpsFileType == .fitgz) {
                return try fitfile.decode(
                    alloc,
                    try ungzipped.readToEndAlloc(alloc, maxFileSize(gpsFileType)),
                );
            } else {
                return try gpxfile.parse(
                    alloc,
                    try ungzipped.readToEndAlloc(alloc, maxFileSize(gpsFileType)),
                );
            }
        },
    }
}

fn readFileContent(
    alloc: Allocator,
    file: []const u8,
    file_type: Type,
) ![]u8 {
    return try fs.cwd().readFileAlloc(alloc, file, maxFileSize(file_type));
}

fn maxFileSize(file_type: Type) usize {
    return switch (file_type) {
        .fit => fit_file_size_max,
        .gpx => gpx_file_size_max,
        .fitgz => fit_file_size_max,
        .gpxgz => gpx_file_size_max,
    };
}
