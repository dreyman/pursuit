const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const posix = std.posix;
const assert = std.debug.assert;

const storage = @import("core/storage.zig");

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
            error.HomeDirNotFound => try writeErrorAndExit("home dir not found.", .{}),
            error.PathAlreadyExists => try writeErrorAndExit("already initialized.", .{}),
            else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        };
        try writeAndExit("Done", .{});
    }

    pub fn addFitActivity(alloc: mem.Allocator, fit_file_path: []const u8) !void {
        const cwd_path = try fs.cwd().realpathAlloc(alloc, ".");
        defer alloc.free(cwd_path);

        const absolute_path = try std.fs.path.resolve(alloc, &.{ cwd_path, fit_file_path });
        defer alloc.free(absolute_path);

        const file = fs.openFileAbsolute(absolute_path, .{}) catch |err| switch (err) {
            error.FileNotFound => try writeErrorAndExit("file not found", .{}),
            else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        };
        defer file.close();

        storage.addFitActivity(alloc, file) catch |err| switch (err) {
            else => try writeErrorAndExit("{s}", .{@errorName(err)}),
        };
    }
};

test "wip" {
    try std.testing.expect(4 == 4);
}
