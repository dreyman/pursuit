const GpsFile = @This();

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
        else => unreachable,
        // .gpx => return try gpx_import.importGpxFilePath(a, file_path),
        // .fitgz, .gpxgz => {
        //     const ungzipped = try storage.ungzip(a, file_path);
        //     defer {
        //         ungzipped.close();
        //         // storage.deleteTempFile(a, ungzipped_file); // fixme
        //     }
        //     if (gpsFileType == .fitgz) {
        //         return try fit_import.importFitFile(a, ungzipped);
        //     } else {
        //         return try gpx_import.importGpxFile(a, ungzipped);
        //     }
        // },
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
        else => unreachable,
    };
}

const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const Allocator = mem.Allocator;

const data = @import("data.zig");
const fitfile = @import("gpsfile/fitfile.zig");
