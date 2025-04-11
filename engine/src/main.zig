const std = @import("std");
const mem = std.mem;
const fatal = std.zig.fatal;
const assert = std.debug.assert;

const app = @import("app.zig");
const setup = @import("setup.zig");
const Storage = @import("Storage.zig");

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
        const storage_path = args.next();
        var default_storage: ?[]const u8 = null;
        if (storage_path == null) {
            default_storage = try app.defaultStorageDirPath(allocator);
        }
        defer if (default_storage == null) allocator.free(default_storage.?);

        setup.install(allocator, storage_path orelse default_storage.?) catch |err|
            switch (err) {
            else => fatal("error: {s}", .{@errorName(err)}),
        };
        try writeAndExit("done.", .{});
    }

    if (mem.eql(u8, command, "add")) {
        const filepath = args.next() orelse {
            fatal("expected file path. (Supported files: " ++ app.supported_files ++ ")", .{});
        };
        var storage_dir: ?[]const u8 = null;
        const next = args.next();
        if (next) |arg| {
            if (mem.eql(u8, arg, "--storage")) {
                const path = args.next() orelse fatal("expected parameter after {s}", .{arg});
                storage_dir = path;
            } else {
                fatal("unrecognized argument: '{s}'", .{arg});
            }
        }
        if (storage_dir == null)
            storage_dir = try app.defaultStorageDirPath(allocator);
        var storage = try Storage.create(allocator, storage_dir.?);
        defer storage.destroy();

        const id = app.importGpsFile(allocator, storage, filepath, null) catch |err| switch (err) {
            else => fatal("{s}", .{@errorName(err)}),
        };
        try writeAndExit("done. id={d}", .{id});
    }

    // if (mem.eql(u8, command, "strava")) {
    //     const strava = @import("strava.zig");
    //     const strava_archive_dir = args.next() orelse {
    //         try writeAndExit("expected strava export dir path", .{});
    //     };

    //     strava.importStravaArchive(
    //         allocator,
    //         storage,
    //         strava_archive_dir,
    //         .{ .save_activities_to_db = true },
    //     ) catch |err| switch (err) {
    //         else => try writeAndExit("error: {s}", .{@errorName(err)}),
    //     };
    //     try writeAndExit("done.", .{});
    // }

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
