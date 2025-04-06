const std = @import("std");
const mem = std.mem;
const ArrayList = std.ArrayList;
const print = std.debug.print;
const fit_decoder = @import("decode.zig");
const fit_debug = @import("debug.zig");
const protocol = @import("fit_protocol.zig");
const profile = @import("profile.zig");
const Fit = protocol.Fit;

pub const activity_file_id = 4;

pub const Error = error{
    NotAnActivity,
    Invalid,
    FitActivityMultipleSessions,
};

// pub fn decodeRecords(
//     alloc: mem.Allocator,
// ) void {}

pub const Activity = struct {
    alloc: mem.Allocator,
    file_id: *profile.FileId,
    records: ArrayList(*profile.Record),
    // session: *profile.Session,
    activity: *profile.Activity,

    pub fn deinit(self: Activity) void {
        self.alloc.destroy(self.file_id);
        // self.alloc.destroy(self.session);
        self.alloc.destroy(self.activity);
        for (self.records.items) |rec| {
            self.alloc.destroy(rec);
        }
        self.records.deinit();
    }

    pub fn create(alloc: mem.Allocator, fit: Fit) !Activity {
        if (fit.messages.items.len < 2) return Error.Invalid;
        const first = fit.messages.items[0];
        if (first.global_id != @intFromEnum(profile.CommonMessage.file_id))
            return Error.Invalid;
        const file_id = profile.decodeFileId(alloc, first);
        if (file_id.file_type != profile.file_id_type_activity)
            return Error.NotAnActivity;

        var records = ArrayList(*profile.Record).init(alloc);
        errdefer records.deinit();
        // fixme if there's no session data in the source fit then this will remain undefined
        // var session: *profile.Session = undefined;
        // var sessions_count: usize = 0;
        var activity: *profile.Activity = undefined;
        for (1..fit.messages.items.len) |i| {
            const msg = fit.messages.items[i];
            const profile_message = std.meta.intToEnum(profile.CommonMessage, msg.global_id) catch
                continue;
            switch (profile_message) {
                .record => {
                    const record = profile.decodeRecord(alloc, msg);
                    if (record.lat != null and record.lon != null) {
                        records.append(record) catch unreachable;
                    } else {
                        alloc.destroy(record);
                    }
                },
                // .session => {
                //     session = profile.decodeSession(alloc, msg);
                //     sessions_count += 1;
                //     if (sessions_count > 1)
                //         return Error.FitActivityMultipleSessions;
                // },
                .activity => activity = profile.decodeActivity(alloc, msg),
                else => {},
            }
        }

        return .{
            .alloc = alloc,
            .file_id = file_id,
            .records = records,
            // .session = session,
            .activity = activity,
        };
    }
};
