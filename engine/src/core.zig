const std = @import("std");
const mem = std.mem;

const fit = @import("fit/fit.zig");
const calc = @import("calc.zig");
const geo = @import("geo.zig");

pub const Summary = struct {
    distance: u32,
    total_time: u32,
    moving_time: u32,
    pauses_count: u16,
    pauses_len: u32,
    untracked_distance: u32,
};

pub fn routeFromFit(
    allocator: mem.Allocator,
    activity: fit.Activity,
    unit: geo.CoordUnit,
) geo.Route {
    var route = geo.Route.init(allocator, activity.records.items.len) catch unreachable;
    for (activity.records.items, 0..) |rec, i| {
        route.points[i] = .{
            .lat = calc.convertSemicircles(rec.lat.?, unit),
            .lon = calc.convertSemicircles(rec.lon.?, unit),
        };
        route.timestamps[i] = rec.timestamp + fit.protocol.timestamp_offset;
    }
    return route;
}

// pub const LatLon = struct {
//     lat: f32,
//     lon: f32,

//     pub fn createFromFit(
//         alloc: mem.Allocator,
//         fit_activity: fit.Activity,
//     ) ![]LatLon {
//         var latlons = try alloc.alloc(LatLon, fit_activity.records.items.len);
//         for (fit_activity.records.items, 0..) |rec, i| {
//             if (rec.lat == null or rec.lon == null) {
//                 continue;
//             }
//             latlons[i] = .{
//                 .lat = calc.semicirclesToRadians(rec.lat.?),
//                 .lon = calc.semicirclesToRadians(rec.lon.?),
//             };
//         }
//         var dist: f64 = 0;
//         for (1..latlons.len) |i| {
//             const prev = latlons[i - 1];
//             const curr = latlons[i];
//             dist += calc.distance(prev, curr);
//         }
//         std.debug.print("\n\n\t\t\tDISTANCE: {d}\n\n", .{dist});
//         for (latlons) |item| {
//             var point = item;
//             point.lat = std.math.radiansToDegrees(point.lat);
//             point.lon = std.math.radiansToDegrees(point.lon);
//         }
//         return latlons;
//     }
// };

pub fn createSummary(route: geo.Route) Summary {
    var summary: Summary = .{
        .distance = 0,
        .total_time = 0,
        .moving_time = 0,
        .pauses_count = 0,
        .pauses_len = 0,
        .untracked_distance = 0,
    };
    var distance: f64 = 0;
    var untracked_distance: f64 = 0;
    if (route.points.len < 2) return summary;
    for (1..route.points.len) |i| {
        const cur = route.points[i];
        const prev = route.points[i - 1];
        const t1 = route.timestamps[i - 1];
        const t2 = route.timestamps[i];
        if (t2 - t1 > 1) {
            summary.pauses_count += 1;
            summary.pauses_len += t2 - t1;
            untracked_distance += calc.distance(prev, cur);
        } else {
            distance += calc.distance(prev, cur);
        }
    }
    summary.distance = @intFromFloat(distance * 100);
    summary.untracked_distance = @intFromFloat(untracked_distance * 100);
    summary.total_time = route.timestamps[route.timestamps.len - 1] - route.timestamps[0];
    summary.moving_time = summary.total_time - summary.pauses_len;
    return summary;
}

// pub fn fitActivityDistance(ac: fit.Activity) f64 {
//     var res: f64 = 0;
//     var pauses: usize = 0;
//     var pauses_len: u32 = 0;
//     if (ac.records.items.len < 2) return 0;
//     for (1..ac.records.items.len) |i| {
//         const cur = ac.records.items[i];
//         const prev = ac.records.items[i - 1];

//         if (cur.timestamp - prev.timestamp > 1) {
//             pauses += 1;
//             pauses_len += cur.timestamp - prev.timestamp;
//         } else {
//             const point1 = LatLon{
//                 .lat = calc.semicirclesToRadians(prev.lat.?),
//                 .lon = calc.semicirclesToRadians(prev.lon.?),
//             };
//             const point2 = LatLon{
//                 .lat = calc.semicirclesToRadians(cur.lat.?),
//                 .lon = calc.semicirclesToRadians(cur.lon.?),
//             };
//             res += calc.distance(point1, point2);
//         }
//     }
//     std.debug.print("PAUSES:     {d}\n", .{pauses});
//     std.debug.print("PAUSES LEN: {d}\n", .{pauses_len});
//     const total_time = ac.records.items[ac.records.items.len - 1].timestamp - ac.records.items[0].timestamp;
//     const moving_time = total_time - pauses_len;
//     const th = total_time / 3600;
//     const tm = (total_time - th * 3600) / 60;
//     const ts = total_time % 60;
//     const mh = moving_time / 3600;
//     const mm = (moving_time - mh * 3600) / 60;
//     const ms = moving_time % 60;
//     std.debug.print("moving time: {d}:{d}:{d}\n", .{ mh, mm, ms });
//     std.debug.print("total time:  {d}:{d}:{d}\n", .{ th, tm, ts });
//     std.debug.print("SESSION data:\n", .{});
//     std.debug.print("{}\n", .{std.json.fmt(ac.session, .{ .whitespace = .indent_4 })});
//     return res;
// }

// test fitActivityDistance {
//     const t = std.testing;
//     const file = try std.fs.openFileAbsolute("/home/ihor/Downloads/terra_incognita.fit", .{});
//     defer file.close();
//     const ac = try fit.decodeActivityFromFile(t.allocator, file);
//     defer ac.deinit();

//     const distance = fitActivityDistance(ac);

//     std.debug.print("DISTANCE: {d}\n", .{distance});

//     try t.expect(distance > 0);
// }
