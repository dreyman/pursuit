const std = @import("std");
const mem = std.mem;
const math = std.math;
const fs = std.fs;
const json = std.json;
const posix = std.posix;
const assert = std.debug.assert;

const app = @import("core/app.zig");
const storage = @import("storage.zig");
const fit = @import("fit/fit.zig");
const core = @import("core.zig");
const file_import = @import("file_import.zig");

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
        try Command.setup(allocator);
        return;
    }

    if (mem.eql(u8, command, "version")) {
        try writeAndExit("0.0.1-wip", .{}, 1);
    }

    if (mem.eql(u8, command, "add")) {
        const filepath = args.next() orelse {
            try writeAndExit("err: expected fit file path", .{}, 1);
        };
        Command.importFromFile(allocator, filepath) catch |err| switch (err) {
            else => try writeAndExit("err: ", .{}, 1),
        };
    }

    // if (mem.eql(u8, command, "check")) {
    //     const db = @import("db/db.zig");
    //     try db.check();
    //     try writeAndExit("ALL GOOD\n", .{}, 1);
    // }

    try writeAndExit(help, .{}, 0);
}

fn writeResultAndExit(stats: core.Stats) !noreturn {
    try json.stringify(
        stats,
        .{ .whitespace = .indent_4 },
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
    \\  add        Add gps activity from the fit or gpx file at <path>.
    \\  version    Print the version.
    \\  init       Initialize pursuit app
;

const Command = struct {
    pub fn setup(alloc: mem.Allocator) !void {
        app.setup(alloc) catch |err| switch (err) {
            else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        };
        try writeAndExit("done.", .{}, 0);
    }

    pub fn importFromFile(alloc: mem.Allocator, file_path: []const u8) !void {
        const cwd_path = try fs.cwd().realpathAlloc(alloc, ".");
        defer alloc.free(cwd_path);

        const gps_file_path = try std.fs.path.resolve(
            alloc,
            &.{ cwd_path, file_path },
        );
        defer alloc.free(gps_file_path);

        const imported = file_import.importGpsFile(alloc, gps_file_path) catch |err| switch (err) {
            else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        };

        storage.addEntry(
            alloc,
            gps_file_path,
            imported.route,
            imported.stats,
        ) catch |err| switch (err) {
            else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        };

        try writeResultAndExit(imported.stats);
    }
};
