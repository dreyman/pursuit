const std = @import("std");
const mem = std.mem;

const fit = @import("fit/fit.zig");
const calc = @import("calc.zig");
const geo = @import("geo.zig");

pub const Type = enum {
    cycling,
    running,
    walking,
    hiking,

    pub fn fromFitSport(sport: fit.Sport) Type {
        return switch (sport) {
            .running => Type.running,
            .cycling => Type.cycling,
            .walking => Type.walking,
            .hiking => Type.hiking,
        };
    }
};

// pub fn routeFromFit(
//     allocator: mem.Allocator,
//     activity: fit.Activity,
//     unit: geo.CoordUnit,
// ) geo.Route {
//     var route = geo.Route.init(allocator, activity.records.items.len) catch unreachable;
//     for (activity.records.items, 0..) |rec, i| {
//         route.points[i] = .{
//             .lat = calc.convertSemicircles(rec.lat.?, unit),
//             .lon = calc.convertSemicircles(rec.lon.?, unit),
//         };
//         route.timestamps[i] = rec.timestamp + fit.protocol.timestamp_offset;
//     }
//     return route;
// }
