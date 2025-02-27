const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const posix = std.posix;
const json = std.json;

const fit = @import("fit/fit.zig");
const fit_protocol = @import("fit/fit_protocol.zig");
const Activity = @import("core/activity.zig").Activity;
const core = @import("core.zig");
const geo = @import("geo.zig");

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

pub fn addEntry(
    allocator: mem.Allocator,
    original_file_path: []const u8,
    route: geo.Route,
    summary: core.Summary,
) !void {
    const entry_dir_path = try getEntryDirPath(allocator, route.timestamps[0]);
    defer allocator.free(entry_dir_path);
    try fs.makeDirAbsolute(entry_dir_path);
    errdefer fs.deleteDirAbsolute(entry_dir_path) catch unreachable; // fixme

    const original_copy_path = try std.fmt.allocPrint(
        allocator,
        "{s}/original.fit", // fixme mb it's better to preserve original file name
        .{entry_dir_path},
    );
    defer allocator.free(original_copy_path);
    try fs.copyFileAbsolute(original_file_path, original_copy_path, .{});
    errdefer fs.deleteFileAbsolute(original_copy_path) catch unreachable; // fixme

    const route_file_path = try std.fmt.allocPrint(allocator, "{s}/route", .{entry_dir_path});
    defer allocator.free(route_file_path);
    const complete_route_file_path = try std.fmt.allocPrint(allocator, "{s}/complete_route", .{entry_dir_path});
    defer allocator.free(complete_route_file_path);

    try createRouteFile(route_file_path, route, false);
    try createRouteFile(complete_route_file_path, route, true);

    const summary_file_path = try std.fmt.allocPrint(allocator, "{s}/summary.json", .{entry_dir_path});
    defer allocator.free(summary_file_path);
    const summary_file = try fs.createFileAbsolute(summary_file_path, .{});
    defer summary_file.close();
    errdefer fs.deleteFileAbsolute(summary_file_path) catch unreachable; // fixme

    try json.stringify(
        summary,
        .{ .whitespace = .indent_4 },
        summary_file.writer(),
    );
}

fn createRouteFile(
    file_path: []const u8,
    route: geo.Route,
    include_time: bool,
) !void {
    const file = try fs.createFileAbsolute(file_path, .{});
    defer file.close();
    errdefer fs.deleteFileAbsolute(file_path) catch unreachable; // fixme

    const writer = file.writer();
    try writer.writeInt(u32, @intCast(route.points.len), .big);
    for (route.points, 0..) |point, i| {
        try writer.writeAll(&mem.toBytes(point.lat));
        try writer.writeAll(&mem.toBytes(point.lon));
        if (include_time) {
            try writer.writeAll(&mem.toBytes(route.timestamps[i]));
        }
        // try writer.writeInt(u32, @as(u32, @bitCast(latlon.lat)), .big);
        // try writer.writeInt(u32, @as(u32, @bitCast(latlon.lon)), .big);
    }
}

// pub fn addFromFile(fit_activity_file_path: []const u8) !void {
//     // parse fit activity => mb some sort of decodeActivitySimple
//     //      which produces 3 arrays []f32 lat, []f32 lon, []u32 timestamp

//     // copy original file
//     // create route bin file
//     // create route+time bin file
//     // create summary json file
// }

pub fn addActivity(
    alloc: mem.Allocator,
    activity: Activity,
    file_path: []const u8,
    points: []geo.Point(),
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
    // write route to file
    const route_file_path = try std.fmt.allocPrint(alloc, "{s}/route", .{acitivity_dir});
    defer alloc.free(route_file_path);
    const file = try fs.createFileAbsolute(route_file_path, .{});
    defer file.close();
    const writer = file.writer();
    try writer.writeInt(u32, @intCast(points.len), .big);
    try writer.writeInt(u32, @intCast(points.len), .big); // reserved kinda
    for (points) |point| {
        try writer.writeAll(&mem.toBytes(point.lat));
        try writer.writeAll(&mem.toBytes(point.lon));
        // try writer.writeInt(u32, @as(u32, @bitCast(latlon.lat)), .big);
        // try writer.writeInt(u32, @as(u32, @bitCast(latlon.lon)), .big);
    }
}

fn getStorageDirPath(alloc: mem.Allocator) ![]const u8 {
    const home_path = posix.getenv("HOME") orelse return Error.HomeDirNotFound;
    return std.fmt.allocPrint(alloc, "{s}/{s}", .{ home_path, wf_dir_name }) catch unreachable;
}

fn getEntryDirPath(a: mem.Allocator, id: u32) ![]const u8 {
    const storage = try getStorageDirPath(a);
    defer a.free(storage);
    return std.fmt.allocPrint(
        a,
        "{s}/{d}",
        .{ storage, id },
    ) catch unreachable;
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
