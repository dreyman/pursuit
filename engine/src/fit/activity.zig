const std = @import("std");
const ArrayList = std.ArrayList;
const t = std.testing;
const print = std.debug.print;
const fit_decoder = @import("decode.zig");
const fit_debug = @import("debug.zig");
const util = @import("util.zig");
const protocol = @import("fit_protocol.zig");
const profile = @import("profile.zig");
const Fit = protocol.Fit;

pub const activity_file_id = 4;

pub const Error = error{
    NotAnActivity,
    Invalid,
    FitActivityMultipleSessions,
};

pub const Activity = struct {
    file_id: profile.FileId,
    records: ArrayList(profile.Record),
    session: profile.Session,
    activity: profile.Activity,

    pub fn create(alloc: std.mem.Allocator, fit: Fit) !Activity {
        if (fit.messages.items.len < 2) return Error.Invalid;
        const first = fit.messages.items[0];
        if (first.global_id != @intFromEnum(profile.CommonMessage.file_id)) return Error.Invalid;
        const file_id = profile.decodeFileId(first) orelse unreachable;
        if (file_id.file_type != profile.file_id_type_activity) return Error.NotAnActivity;

        var records = ArrayList(profile.Record).init(alloc);
        errdefer records.deinit();
        // fixme if there's no session data in the source fit then this will stay undefined
        var session: profile.Session = undefined;
        var sessions_count: usize = 0;
        var activity: profile.Activity = undefined;
        for (1..fit.messages.items.len) |i| {
            const msg = fit.messages.items[i];
            switch (std.meta.intToEnum(profile.CommonMessage, msg.global_id) catch continue) {
                .record => {
                    const record = profile.decodeRecord(msg) orelse unreachable;
                    records.append(record) catch unreachable;
                },
                .session => {
                    session = profile.decodeSession(msg) orelse unreachable;
                    sessions_count += 1;
                    if (sessions_count > 1) {
                        return Error.FitActivityMultipleSessions;
                    }
                },
                .activity => activity = profile.decodeActivity(msg) orelse unreachable,
                else => {},
            }
        }

        return .{
            .file_id = file_id,
            .records = records,
            .session = session,
            .activity = activity,
        };
    }
};

test "activity creation" {
    const bytes = try util.fileAsBytes(t.allocator, "/home/ihor/code/wild-fields/engine/src/fit/example.fit");
    // defer t.allocator.free(bytes);

    var decoded_fit = try fit_decoder.decode(t.allocator, bytes);
    defer decoded_fit.deinit();

    const activity = try Activity.create(t.allocator, decoded_fit);
    defer activity.records.deinit();

    fit_debug.printAsJson("File ID", activity.file_id);
    fit_debug.printAsJson("Session", activity.session);
    fit_debug.printAsJson("Activity", activity.activity);
    const print_acitivities_max = 3;
    for (0..print_acitivities_max) |idx| {
        const rec = activity.records.items[idx];
        std.debug.print("Record {d} {}\n", .{
            idx,
            std.json.fmt(rec, .{ .whitespace = .indent_4 }),
        });
    }
    for (0..print_acitivities_max) |i| {
        const idx = activity.records.items.len - print_acitivities_max + i;
        const rec = activity.records.items[idx];
        std.debug.print("Record {d} {}\n", .{
            idx,
            std.json.fmt(rec, .{ .whitespace = .indent_4 }),
        });
    }

    try t.expect(activity.file_id.file_type == profile.file_id_type_activity);
}
