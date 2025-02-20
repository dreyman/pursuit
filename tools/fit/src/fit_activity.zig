const std = @import("std");
const ArrayList = std.ArrayList;
const t = std.testing;
const print = std.debug.print;
const fit_impl = @import("fit_impl.zig");
const fit_debug = @import("debug.zig");
const util = @import("util.zig");
const fitp = @import("fit_protocol.zig");
const profile = @import("fit_profile.zig");
const Fid = fitp.Fid;
const FitData = fitp.FitData;

pub const activity_file_id = 4;

pub const Error = error{ NotAnActivity, Invalid };

pub const Activity = struct {
    fileId: profile.FileId,
    records: ArrayList(profile.Record),
    events: ArrayList(profile.Event),
};

pub fn createActivity(alloc: std.mem.Allocator, fit: FitData) !Activity {
    if (fit.messages.items.len < 2) return Error.Invalid;
    const first = fit.messages.items[0];
    if (first.global_id != profile.message_file_id) return Error.Invalid;
    const fileId = try profile.FileId.create(first);
    if (fileId.type != profile.message_file_id_type_activity) return Error.NotAnActivity;

    var records = ArrayList(profile.Record).init(alloc);
    errdefer records.deinit();
    for (1..fit.messages.items.len) |idx| {
        const msg = fit.messages.items[idx];
        if (msg.global_id == profile.message_record) {
            const record = try profile.Record.create(msg);
            records.append(record) catch unreachable;
        }
    }

    return .{ .fileId = fileId, .records = records };
}

test "activity creation" {
    const bytes = try util.fileAsBytes(t.allocator, "/home/ihor/code/zig-plgrnd/example.fit");
    defer t.allocator.free(bytes);

    var fit = try fit_impl.createFitData(t.allocator, bytes);
    defer fit.deinit();

    const activity = try createActivity(t.allocator, fit);
    defer activity.records.deinit();

    for (activity.records.items) |rec| {
        fit_debug.printRecord(rec);
    }

    try t.expect(activity.fileId.type == profile.message_file_id_type_activity);
}
