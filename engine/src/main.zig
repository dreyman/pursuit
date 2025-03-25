const std = @import("std");
const mem = std.mem;
const assert = std.debug.assert;

const app = @import("app.zig");

const version = "0.0.1-wip";

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

    if (mem.eql(u8, command, "help")) try writeAndExit(help, .{});
    if (mem.eql(u8, command, "version")) try writeAndExit(version, .{});

    if (mem.eql(u8, command, "init")) {
        app.setup(allocator) catch |err| switch (err) {
            else => try writeAndExit("error: {s}", .{@errorName(err)}),
        };
        try writeAndExit("done.", .{});
    }

    if (mem.eql(u8, command, "add")) {
        const filepath = args.next() orelse {
            try writeAndExit("error: expected file path\nSupported files: .fit, .gpx, .fit.gz, .gpx.gz", .{});
        };
        const id = app.importGpsFile(allocator, filepath) catch |err| switch (err) {
            else => try writeAndExit("error: {s}", .{@errorName(err)}),
        };
        try writeAndExit("done. id={d}", .{id});
    }

    if (mem.eql(u8, command, "strava")) {
        const strava = @import("strava.zig");
        const dir = args.next() orelse {
            try writeAndExit("error: expected strava export dir path", .{});
        };
        strava.importStravaArchive(allocator, dir) catch |err| switch (err) {
            else => try writeAndExit("error: {s}", .{@errorName(err)}),
        };
        try writeAndExit("done.", .{});
    }

    try writeAndExit(help, .{});
}

pub const help =
    \\Usage:
    \\  wf version
    \\  wf help
    \\  wf init
    \\  wf add <path>
    \\Commands:
    \\  add        Add gps activity from the fit or gpx file at <path>.
    \\  version    Print the version.
    \\  init       Initialize pursuit app
;

fn writeAndExit(comptime format: []const u8, args: anytype) !noreturn {
    const out = std.io.getStdOut().writer();
    try out.print(format, args);
    try out.print("\n", .{});
    std.process.exit(0);
}
