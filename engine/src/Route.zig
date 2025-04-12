const Route = @This();

const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const math = std.math;

const constants = @import("constants.zig");
const geo = @import("geo.zig");

gpa: mem.Allocator,
lat: []f32,
lon: []f32,
time: []u32,

pub fn init(a: mem.Allocator, size: usize) !Route {
    return .{
        .gpa = a,
        .lat = try a.alloc(f32, size),
        .lon = try a.alloc(f32, size),
        .time = try a.alloc(u32, size),
    };
}

pub fn deinit(r: *Route) void {
    r.gpa.free(r.lat);
    r.gpa.free(r.lon);
    r.gpa.free(r.time);
}

pub fn point(route: *const Route, i: usize) geo.Point {
    return .{
        .lat = route.lat[i],
        .lon = route.lon[i],
    };
}

pub fn startPoint(route: *const Route) geo.Point {
    return route.point(0);
}

pub fn finishPoint(route: *const Route) geo.Point {
    return route.point(route.len() - 1);
}

pub fn toDegrees(route: *Route) void {
    for (0..route.len()) |i| {
        route.lat[i] = math.radiansToDegrees(route.lat[i]);
        route.lon[i] = math.radiansToDegrees(route.lon[i]);
    }
}

pub fn len(route: *const Route) usize {
    return route.time.len;
}

pub const CreateFromFileError = error{InvalidRouteFile};

pub fn createFromFile(gpa: mem.Allocator, file: fs.File) !Route {
    // var file = try fs.cwd().openFile(file_path, .{});
    // defer file.close();
    const content = try file.readToEndAlloc(gpa, constants.fit_file_size_max);
    defer gpa.free(content);

    if (content.len % 12 != 0) return CreateFromFileError.InvalidRouteFile;

    const route = try Route.init(gpa, content.len / 12);
    var pos: usize = 0;
    var i: usize = 0;
    while (pos < content.len) : (pos += 12) {
        route.lat[i] = mem.bytesAsValue(f32, content[pos .. pos + 4]).*;
        route.lon[i] = mem.bytesAsValue(f32, content[pos + 4 .. pos + 8]).*;
        route.time[i] = mem.bytesAsValue(u32, content[pos + 8 .. pos + 12]).*;
        i += 1;
    }
    return route;
}
