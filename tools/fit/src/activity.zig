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

pub const Error = error{ NotAnActivity, Invalid };

pub const Activity = struct {
    file_id: profile.FileId,
    records: ArrayList(profile.Record),
    session: profile.Session,
    activity: profile.Activity,
};

pub fn createActivity(alloc: std.mem.Allocator, fit: Fit) !Activity {
    if (fit.messages.items.len < 2) return Error.Invalid;
    const first = fit.messages.items[0];
    if (first.global_id != profile.message_file_id) return Error.Invalid;
    const file_id = profile.decodeFileId(first) orelse unreachable;
    if (file_id.file_type != profile.message_file_id_type_activity) return Error.NotAnActivity;

    var records = ArrayList(profile.Record).init(alloc);
    errdefer records.deinit();
    var session: profile.Session = undefined;
    var activity: profile.Activity = undefined;
    for (1..fit.messages.items.len) |idx| {
        const msg = fit.messages.items[idx];
        switch (std.meta.intToEnum(profile.MessageType, msg.global_id) catch continue) {
            .record => {
                const record = profile.decodeRecord(msg) orelse unreachable;
                records.append(record) catch unreachable;
            },
            .session => session = profile.decodeSession(msg) orelse unreachable,
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

test "activity creation" {
    const bytes = try util.fileAsBytes(t.allocator, "/home/ihor/code/zig-plgrnd/example.fit");
    defer t.allocator.free(bytes);

    var decoded_fit = try fit_decoder.decode(t.allocator, bytes);
    defer decoded_fit.deinit();

    const activity = try createActivity(t.allocator, decoded_fit);
    defer activity.records.deinit();

    fit_debug.printAsJson("File ID", activity.file_id);
    fit_debug.printAsJson("Session", activity.session);
    fit_debug.printAsJson("Activity", activity.activity);
    const print_acitivities_max = 3;
    for (activity.records.items, 0..) |rec, idx| {
        if (idx == print_acitivities_max) break;
        fit_debug.printAsJson("Record", rec);
    }

    try t.expect(activity.file_id.file_type == profile.message_file_id_type_activity);
}
