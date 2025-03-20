const std = @import("std");
const ArrayList = std.ArrayList;
const mem = std.mem;
const fs = std.fs;
const testing = std.testing;

const Activity = struct {
    allocator: mem.Allocator,
    id: []u8,
    name: []u8,
    file: []u8,
    kind: []u8,
    bike: []u8,

    pub fn destroy(a: *const Activity) void {
        a.allocator.free(a.id);
        a.allocator.free(a.name);
        a.allocator.free(a.file);
        a.allocator.free(a.kind);
        a.allocator.free(a.bike);
    }
};

fn parseActivities(a: mem.Allocator, csv_path: []const u8) !ArrayList(Activity) {
    const csv = try fs.openFileAbsolute(csv_path, .{});
    defer csv.close();
    const r = csv.reader();
    try r.skipUntilDelimiterOrEof('\n');
    const size: usize = 100;
    var list = try ArrayList(Activity).initCapacity(a, size);
    for (0..size) |_| {
        const id = try r.readUntilDelimiterAlloc(a, ',', 100);
        try skip(r, true);
        const name = try r.readUntilDelimiterAlloc(a, ',', 10_000);
        const kind = try r.readUntilDelimiterAlloc(a, ',', 10_000);
        try skip(r, true);
        try skip(r, false);
        try skip(r, false);
        try skip(r, false);
        try skip(r, false);
        try skip(r, false);
        try skip(r, false);
        const bike = try r.readUntilDelimiterAlloc(a, ',', 10_000);
        const file = try r.readUntilDelimiterAlloc(a, ',', 1000);
        try list.append(.{
            .allocator = a,
            .id = id,
            .name = name,
            .file = file,
            .kind = kind,
            .bike = bike,
        });
        try r.skipUntilDelimiterOrEof('\n');
    }
    return list;
}

test parseActivities {
    const path = "/home/ihor/stuff/export_53360041/activities.csv";
    const list = try parseActivities(testing.allocator, path);
    defer {
        for (list.items) |item| {
            item.destroy();
        }
        list.deinit();
    }

    for (list.items) |item| {
        std.debug.print("{s}:[{s}:{s}]:{s} ({s})\n", .{
            item.id,
            item.bike,
            item.kind,
            item.name,
            item.file,
        });
    }

    try testing.expect(4 == 4);
}

fn skip(r: anytype, q: bool) !void {
    if (q) {
        try r.skipUntilDelimiterOrEof('"');
        try r.skipUntilDelimiterOrEof('"');
    }
    try r.skipUntilDelimiterOrEof(',');
}

// const Activity = struct {
//     id: u32,
//     date: []u8,
//     name: []u8,
//     type: []u8, // Ride Run
//     description: []u8,
//     elapsed_time: u32, // 5601
//     distance: f32, // 18.96
//     // max_heart_rate: u8, // correct type?
//     // relative_effort: u16, // correct type?
//     commute: bool,
//     private_note: []u8,
//     gear: []u8, // bike shoes etc.
//     filename: []u8,
//     // athlete_weight: f16, // correct type?
//     // bike_weight: f16, // correct type?
//     // elapsed_time: f32,
//     moving_time: u32, // 4567.0
//     // distance: f32,
//     max_speed: f32,
//     avg_speed: f32,
//     elevation_gain: f32,
//     elevation_loss: f32,
//     elevation_low: f32,
//     elevation_high: f32,
//     max_grade: f32,
//     avg_grade: f32,
//     avg_positive_grade: f32,
//     avg_negative_grade: f32,
//     // max_cadence: u16,
//     // avg_cadence: f16,
//     // max_heart_rate: u16,
//     // avg_heart_rate: u16,
//     // max_watts: u16,
//     // avg_watts: u16,
//     // calories: f32,
//     max_temperature: i8,
//     avg_temperature: i8,
//     // relative_effort: u16, // correct type?
//     total_work: u16, // correct type?
//     number_of_runs: u16, // correct type?
//     uphill_time: u16,
//     downhill_time: u16,
//     other_time: u16,
//     perceived_exertion: u16,
//     // type: u8, // correct type?
//     start_time: u32,
//     // weighted_avg_power: u16,
//     // power_count: u16, // correct type?
//     // prefer_perceid_exertion: f16, // correct type?
//     // perceived_relative_effort: u16, // correct type?
//     // commute: f16,
//     // total_weight_lifted: f16,
//     // From Upload
//     // grade_adjustetd_distance: u16,
//     // Weather observation time
//     // Weather condition
//     // weather_temperature: f32,
//     // apparent_temperature: f32,
//     // dewpoint: f32,
//     // humidity: f32,
//     // weather_pressure: f32,
//     // wind_speed: f32,
//     // wind_gust: f32,
//     // wind_bearing: u16,
//     // Percipation intensity
//     // Sunrise time
//     // Sunset time
//     // Moon phase
//     // Bike = 8,939,781.0
//     // Gear
//     // Precipitation Probability
//     // Precipitation type
//     // Cloud Cover
//     // Weather visibility
//     // UV index
//     // Weather ozone
//     // Jump count
//     // Total grit
//     // Average flow
//     // flagged: u16,
//     // avg_elapsed_speed: f32,
//     // dirt_distance: f32,
//     // Newly exported distance
//     // Newly exported dirt distance
//     // acitivity_count: u8,
//     // total_steps: u32,
//     // Carbon saved
//     // Pool length
//     // Tranining load
//     // Intensity
//     // avg_grade_adjusted_pace: f16,
//     // timer_time: u32,
//     // total_cycles: u16,
//     media: []u8,
// };
