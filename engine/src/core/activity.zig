const std = @import("std");

const fit = @import("../fit/fit.zig");

pub const Error = error{
    UnsupportedFitSport,
    UnsupportedFitSession,
};

pub const Activity = struct {
    type: Type,
    timestamp: u32,
    // summary: Summary,

    pub const Type = enum {
        cycling,
        running,
        walking,

        pub fn fromFitSport(sport: fit.Sport) Type {
            return switch (sport) {
                .running => Type.running,
                .cycling => Type.cycling,
                .walking, .hiking => Type.walking,
            };
        }
    };

    // pub const Summary = struct {
    //     distance: u32, // in meters
    //     moving_time: u32,
    //     total_time: u32,
    //     avg_speed: u32,
    // };

    pub fn createFromFit(fit_activity: fit.Activity) !Activity {
        const sport = std.meta.intToEnum(
            fit.Sport,
            fit_activity.session.sport orelse return Error.UnsupportedFitSport,
        ) catch
            return Error.UnsupportedFitSport;
        return .{
            .type = Type.fromFitSport(sport),
            .timestamp = fit_activity.session.timestamp orelse
                return Error.UnsupportedFitSession,
        };
    }
};
