const std = @import("std");
const mem = std.mem;

const fit = @import("fit/fit.zig");
const calc = @import("calc.zig");

pub const LatLon = struct {
    lat: f32,
    lon: f32,

    pub fn createFromFit(
        alloc: mem.Allocator,
        fit_activity: fit.Activity,
    ) ![]LatLon {
        const latlons = try alloc.alloc(LatLon, fit_activity.records.items.len);
        for (fit_activity.records.items, 0..) |rec, i| {
            if (rec.lat == null or rec.lon == null) {
                continue;
            }
            latlons[i] = .{
                .lat = calc.semicirclesToDegrees(rec.lat.?),
                .lon = calc.semicirclesToDegrees(rec.lon.?),
            };
        }
        return latlons;
    }
};
