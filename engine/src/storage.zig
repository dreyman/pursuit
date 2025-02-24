const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const posix = std.posix;

const fit = @import("fit/fit.zig");
const fit_protocol = @import("fit/fit_protocol.zig");
const Activity = @import("core/activity.zig").Activity;
const core = @import("core.zig");

const wf_dir_name = ".wild-fields";

pub const Error = error{HomeDirNotFound} || posix.MakeDirError;

pub const Entry = struct {
    activity: Activity,
    file: []const u8,
};

pub fn create(alloc: mem.Allocator) Error!void {
    const path = try getStorageDirPath(alloc);
    defer alloc.free(path);
    try fs.makeDirAbsolute(path);
}

// copy the file
// parse ...
pub fn addActivity(
    alloc: mem.Allocator,
    activity: Activity,
    file_path: []const u8,
    latlons: []core.LatLon,
) !void {
    const acitivity_dir = try getActivityDirPath(alloc, activity);
    defer alloc.free(acitivity_dir);
    try fs.makeDirAbsolute(acitivity_dir);
    const acitity_file_path = try std.fmt.allocPrint(
        alloc,
        "{s}/{d}.fit", // fixme mb it's better to preserve original file name
        .{ acitivity_dir, fit_protocol.timestamp_offset + activity.timestamp },
    );
    defer alloc.free(acitity_file_path);
    try fs.copyFileAbsolute(file_path, acitity_file_path, .{});
    // write LatLon to file
    const latlon_file_path = try std.fmt.allocPrint(alloc, "{s}/latlon", .{acitivity_dir});
    defer alloc.free(latlon_file_path);
    const file = try fs.createFileAbsolute(latlon_file_path, .{});
    defer file.close();
    const writer = file.writer();
    std.debug.print("Write logs:\n", .{});
    try writer.writeInt(u32, @intCast(latlons.len), .big);
    try writer.writeInt(u32, @intCast(latlons.len), .big); // reserved kinda
    for (latlons, 0..) |latlon, i| {
        if (i < 10) {
            std.debug.print("{d}, {d}\n", .{ latlon.lat, latlon.lon });
        }
        if (i != 0 and i % 300 == 0) {
            std.debug.print("every 300th: {d}, {d}\n", .{ latlon.lat, latlon.lon });
        }
        try writer.writeAll(&mem.toBytes(latlon.lat));
        try writer.writeAll(&mem.toBytes(latlon.lon));
        // try writer.writeInt(u32, @as(u32, @bitCast(latlon.lat)), .big);
        // try writer.writeInt(u32, @as(u32, @bitCast(latlon.lon)), .big);
    }
    std.debug.print("======== write logs ==============", .{});
}

fn getStorageDirPath(alloc: mem.Allocator) ![]const u8 {
    const home_path = posix.getenv("HOME") orelse return Error.HomeDirNotFound;
    return std.fmt.allocPrint(alloc, "{s}/{s}", .{ home_path, wf_dir_name }) catch unreachable;
}

fn getActivityDirPath(alloc: mem.Allocator, activity: Activity) ![]const u8 {
    const storage = try getStorageDirPath(alloc);
    defer alloc.free(storage);
    return std.fmt.allocPrint(
        alloc,
        "{s}/{d}",
        .{ storage, fit_protocol.timestamp_offset + activity.timestamp },
    ) catch unreachable;
}

test "lat lon parse" {
    const file = try std.fs.openFileAbsolute("/home/ihor/.wild-fields/1738503741/latlon", .{});
    defer file.close();

    // const bytes: []u8 = try file.readToEndAlloc(std.testing.allocator, (try file.stat()).size);
    // defer std.testing.allocator.free(bytes);
    const reader = file.reader();

    // try std.testing.expect(bytes.len % 16 == 0);

    // std.debug.print("LEN: {d}\n", .{bytes.len});
    // std.debug.print("REC: {d}\n", .{bytes.len / 16});

    // const lat: f64 = std.mem.bytesToValue(f64, bytes[0..8]);
    // const lon: f64 = std.mem.bytesToValue(f64, bytes[8..16]);
    // for (0..20) |_| {
    //     const lat: f32 = @bitCast(try reader.readInt(u32, .big));
    //     const lon: f32 = @bitCast(try reader.readInt(u32, .big));
    //     std.debug.print("{d}, {d}\n", .{ lat, lon });
    // }
    const size: u32 = try reader.readInt(u32, .big);
    _ = try reader.readInt(u32, .big);
    std.debug.print("SIZE: {d}\n", .{size});
    var buf: [4]u8 = undefined;
    for (0..size) |i| {
        _ = try reader.readAtLeast(buf[0..], 4);
        const lat: f32 = std.mem.bytesToValue(f32, buf[0..]);
        _ = try reader.readAtLeast(buf[0..], 4);
        const lon: f32 = std.mem.bytesToValue(f32, buf[0..]);
        if (i % 300 == 0) {
            std.debug.print("{d}, {d}\n", .{ lat, lon });
        }
    }

    // const size = @sizeOf(f64);
    // const pos: usize = 45;
    // const lat_bytes = bytes[pos * 2 * size .. pos * 2 * size + size];
    // const lon_bytes = bytes[pos * 2 * size + size .. pos * 2 * size + size + size];
    // // const lat = @as(f64, @bitCast(lat_bytes));
    // // const lon = @as(f64, @bitCast(lon_bytes));
    // const lat: *f64 = @ptrCast(lat_bytes.ptr);
    // const lon: *f64 = @ptrCast(lon_bytes.ptr);
    // std.debug.print("lat = {d}\n", .{lat});
    // std.debug.print("lon = {d}\n", .{lon});
}
