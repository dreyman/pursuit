const std = @import("std");
const mem = std.mem;
const math = std.math;
const fs = std.fs;
const json = std.json;
const posix = std.posix;
const assert = std.debug.assert;

const storage = @import("storage.zig");
const fit = @import("fit/fit.zig");
const geo = @import("geo.zig");
const file_import = @import("file_import.zig");

const wf_dir_name = ".wild-fields";

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    assert(args.skip());
    const command = args.next() orelse {
        try writeAndExit(help, .{}, 1);
    };

    if (mem.eql(u8, command, "help")) {
        try writeAndExit(help, .{}, 1);
    }

    if (mem.eql(u8, command, "init")) {
        try Command.init(allocator);
        return;
    }

    if (mem.eql(u8, command, "version")) {
        try writeAndExit("0.0.1-wip", .{}, 1);
    }

    if (mem.eql(u8, command, "add")) {
        const filepath = args.next() orelse {
            try writeAndExit("err: expected fit file path", .{}, 1);
        };
        Command.addFitActivity(allocator, filepath) catch |err| switch (err) {
            else => try writeAndExit("err: ", .{}, 1),
        };
    }

    try writeAndExit(help, .{}, 0);
}

fn writeResultAndExit(stats: geo.Route.Stats) !noreturn {
    try json.stringify(
        stats,
        .{},
        std.io.getStdOut().writer(),
    );
    std.process.exit(0);
}

fn writeAndExit(comptime format: []const u8, args: anytype, exit_val: u8) !noreturn {
    const out = std.io.getStdOut().writer();
    try out.print(format, args);
    try out.print("\n", .{});
    std.process.exit(exit_val);
}

fn writeErrorAndExit(comptime format: []const u8, args: anytype) !noreturn {
    try writeAndExit("error: " ++ format, args, 1);
}

pub const help =
    \\Usage:
    \\  wf version
    \\  wf help
    \\  wf init
    \\  wf add <path>
    \\Commands:
    \\  add        Add gps activity from the fit file at <path>.
    \\  version    Print the version.
    \\  init       Initialize wild fields app
;

const Command = struct {
    pub fn init(alloc: mem.Allocator) !void {
        storage.create(alloc) catch |err| switch (err) {
            error.HomeDirNotFound => try writeErrorAndExit("ome dir not found.", .{}),
            error.PathAlreadyExists => try writeErrorAndExit("already initialized.", .{}),
            else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        };
        try writeAndExit("done.", .{}, 0);
    }

    pub fn addFitActivity(alloc: mem.Allocator, file_path: []const u8) !void {
        const cwd_path = try fs.cwd().realpathAlloc(alloc, ".");
        defer alloc.free(cwd_path);

        const gps_file_path = try std.fs.path.resolve(alloc, &.{ cwd_path, file_path });
        defer alloc.free(gps_file_path);

        const imporoted = file_import.importGpsFile(alloc, gps_file_path) catch |err| switch (err) {
            else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        };

        storage.addEntry(alloc, gps_file_path, imporoted.route) catch |err| switch (err) {
            else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        };

        try writeResultAndExit(imporoted.stats);

        // const file = fs.openFileAbsolute(src_file_path, .{}) catch |err| switch (err) {
        //     error.FileNotFound => try writeErrorAndExit("File not found", .{}),
        //     else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        // };
        // defer file.close();

        // const fit_activity = fit.decodeActivityFromFile(alloc, file) catch |err| switch (err) {
        //     else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        // };

        // var route = core.routeFromFit(alloc, fit_activity, .radians);
        // defer route.deinit();
        // const stats = core.createStats(route);
        // for (0..route.points.len) |i| {
        //     var p = &route.points[i];
        //     p.lat = math.radiansToDegrees(p.lat);
        //     p.lon = math.radiansToDegrees(p.lon);
        // }

        // storage.addEntry(alloc, gps_file_path, route) catch |err| switch (err) {
        //     else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        // };

        // try writeResultAndExit(imported.stats);
    }
};
