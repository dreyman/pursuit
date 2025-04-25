const std = @import("std");
const mem = std.mem;
const fatal = std.zig.fatal;
const assert = std.debug.assert;

const app = @import("app.zig");
const setup = @import("setup.zig");
const data = @import("data.zig");
const Storage = @import("Storage.zig");
const Stats = @import("Stats.zig");
const query = @import("query.zig");

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
        const filepath = args.next() orelse
            fatal("expected file path. (Supported files: " ++ app.supported_files ++ ")", .{});
        var storage_path: ?[]const u8 = null;
        const next = args.next();
        if (next) |arg| {
            if (mem.eql(u8, arg, "--storage") or mem.eql(u8, arg, "-s")) {
                const path = args.next() orelse fatal("expected parameter after {s}", .{arg});
                storage_path = path;
            } else {
                fatal("unrecognized argument: '{s}'", .{arg});
            }
        }
        if (storage_path == null)
            storage_path = try app.defaultStorageDirPath(allocator);
        var storage = try Storage.create(allocator, storage_path.?);
        defer storage.destroy();

        const id = app.importGpsFile(allocator, storage, filepath, null) catch |err| switch (err) {
            else => fatal("{s}", .{@errorName(err)}),
        };
        try writeAndExit("done. id={d}", .{id});
    }

    if (mem.eql(u8, command, "recalc")) {
        const id_arg = args.next() orelse fatal("expected id", .{});
        const id = std.fmt.parseInt(data.Pursuit.ID, id_arg, 10) catch
            fatal("invalid id: must be a number, but found: '{s}'", .{id_arg});
        var storage_path: ?[]const u8 = null;
        var calc_options: Stats.CalcStatsOptions = .{};
        for (0..3) |_| {
            const arg = args.next() orelse {
                if (storage_path == null) fatal("expected storage", .{});
                break;
            };
            if (mem.eql(u8, arg, "--storage") or mem.eql(u8, arg, "-s")) {
                const path = args.next() orelse fatal("expected parameter after {s}", .{arg});
                storage_path = path;
            }
            if (mem.eql(u8, arg, "--min-speed")) {
                const ms_arg = args.next() orelse fatal("expected parameter after {s}", .{arg});
                calc_options.min_speed = std.fmt.parseInt(u8, ms_arg, 10) catch
                    fatal("invalid min-speed: must be a number, but found '{s}'", .{ms_arg});
            }
            if (mem.eql(u8, arg, "--max-time-gap")) {
                const mtg_arg = args.next() orelse fatal("expected parameter after {s}", .{arg});
                calc_options.max_time_gap = std.fmt.parseInt(u8, mtg_arg, 10) catch
                    fatal("invalid max-time-gap: must be a number [0-255], but found '{s}'", .{mtg_arg});
            }
        }
        var storage = try Storage.create(allocator, storage_path.?);
        defer storage.destroy();

        _ = app.recalcStats(storage, id, calc_options) catch |err|
            switch (err) {
            else => fatal("{s}", .{@errorName(err)}),
        };
        try writeAndExit("done.", .{});
    }

    if (mem.eql(u8, command, "find")) {
        const timestamp_arg = args.next() orelse fatal("expected timestmap", .{});
        const timestamp = std.fmt.parseInt(u32, timestamp_arg, 10) catch
            fatal("invalid timestamp value", .{});
        const storage_path = "/home/ihor/.pursuit-dev";
        var storage = try Storage.create(allocator, storage_path);
        defer storage.destroy();

        const point = try query.findPointByTimestamp(storage, timestamp) orelse
            try writeAndExit("Not found", .{});

        try writeAndExit("{d}, {d}", .{ point.lat, point.lon });
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
