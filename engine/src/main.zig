const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const posix = std.posix;
const assert = std.debug.assert;

const storage = @import("storage.zig");
const fit = @import("fit/fit.zig");
const Activity = @import("core/activity.zig").Activity;
const core = @import("core.zig");

const wf_dir_name = ".wild-fields";

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    assert(args.skip());
    const command = args.next() orelse {
        try writeAndExit(help, .{});
    };

    if (mem.eql(u8, command, "help")) {
        try writeAndExit(help, .{});
    }

    if (mem.eql(u8, command, "init")) {
        try Command.init(allocator);
        return;
    }

    if (mem.eql(u8, command, "version")) {
        try writeAndExit("0.0.1-wip", .{});
    }

    if (mem.eql(u8, command, "add")) {
        const filepath = args.next() orelse {
            try writeAndExit("err: expected fit file path", .{});
        };
        Command.addFitActivity(allocator, filepath) catch |err| switch (err) {
            else => try writeAndExit("err: ", .{}),
        };
    }

    try writeAndExit(help, .{});
}

fn writeAndExit(comptime format: []const u8, args: anytype) !noreturn {
    const out = std.io.getStdOut().writer();
    try out.print(format, args);
    try out.print("\n", .{});
    std.process.exit(0);
}

fn writeErrorAndExit(comptime format: []const u8, args: anytype) !noreturn {
    try writeAndExit("error: " ++ format, args);
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
        try writeAndExit("done.", .{});
    }

    pub fn addFitActivity(alloc: mem.Allocator, fit_file_path: []const u8) !void {
        const cwd_path = try fs.cwd().realpathAlloc(alloc, ".");
        defer alloc.free(cwd_path);

        const absolute_path = try std.fs.path.resolve(alloc, &.{ cwd_path, fit_file_path });
        defer alloc.free(absolute_path);

        const file = fs.openFileAbsolute(absolute_path, .{}) catch |err| switch (err) {
            error.FileNotFound => try writeErrorAndExit("File not found", .{}),
            else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        };
        defer file.close();

        const fit_activity = fit.decodeActivityFromFile(alloc, file) catch |err| switch (err) {
            else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        };

        const activity = Activity.createFromFit(fit_activity) catch |err| switch (err) {
            error.UnsupportedFitSession => try writeErrorAndExit(
                "fit session contains unsupported data/fields.",
                .{},
            ),
            error.UnsupportedFitSport => try writeErrorAndExit(
                "unknown acitivity type (sport).",
                .{},
            ),
        };
        const latlons = try core.LatLon.createFromFit(alloc, fit_activity);
        defer alloc.free(latlons);

        storage.addActivity(alloc, activity, absolute_path, latlons) catch |err| switch (err) {
            error.PathAlreadyExists => try writeErrorAndExit("already exists.", .{}),
            else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        };

        try writeAndExit("done.", .{});
    }
};

test "wip" {
    const lat: f64 = 48.958845;
    const lon: f64 = 32.22583;
    std.debug.print("48.958845, 32.22583\n", .{});
    std.debug.print("{d}, {d}\n", .{ lat, lon });
    try std.testing.expect(4 == 4);
}
