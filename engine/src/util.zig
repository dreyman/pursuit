const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

const data = @import("data.zig");
const Distance = data.Distance;
const Pursuit = data.Pursuit;

pub fn generateName(
    alloc: Allocator,
    distance: Distance.Meters,
    timestamp: u32,
    kind: Pursuit.Kind,
) ![]u8 {
    const km = @round(@as(f32, @floatFromInt(distance)) / 1_000);
    const date = try timestampToDate(alloc, timestamp);
    defer alloc.free(date);
    return try std.fmt.allocPrint(alloc, "{d}km {s} ({s})", .{
        km,
        kind.verb(),
        date,
    });
}

test generateName {
    const t = std.testing;
    {
        const name = try generateName(t.allocator, 169_345, 1582984325, .cycling);
        defer t.allocator.free(name);
        try t.expect(mem.eql(u8, name, "169km ride (29 feb 2020)"));
    }
    {
        const name = try generateName(t.allocator, 25_755, 1742480215, .running);
        defer t.allocator.free(name);
        try t.expect(mem.eql(u8, name, "26km run (20 mar 2025)"));
    }
}

pub fn timestampToDate(alloc: Allocator, time: u32) ![]u8 {
    const epoch = std.time.epoch;
    const seconds = epoch.EpochSeconds{ .secs = time };
    const epoch_day = seconds.getEpochDay();
    const year_day = epoch_day.calculateYearDay();
    const md = year_day.calculateMonthDay();
    return try std.fmt.allocPrint(alloc, "{d} {s} {d}", .{
        md.day_index + 1,
        @tagName(md.month),
        year_day.year,
    });
}

test timestampToDate {
    const t = std.testing;
    {
        const date = try timestampToDate(t.allocator, 1721895450);
        defer t.allocator.free(date);
        try t.expect(std.mem.eql(u8, date, "25 jul 2024"));
    }
    {
        const date = try timestampToDate(t.allocator, 1742478542);
        defer t.allocator.free(date);
        try t.expect(std.mem.eql(u8, date, "20 mar 2025"));
    }
}
