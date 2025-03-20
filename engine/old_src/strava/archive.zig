const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const fmt = std.fmt;
const testing = std.testing;
const ArrayList = std.ArrayList;

const activities_csv = @import("activities_csv.zig");

const activities_csv_header =
    \\Activity ID,Activity Date,Activity Name,Activity Type,Activity Description,Elapsed Time,Distance,Max Heart Rate,Relative Effort,Commute,Activity Private Note,Activity Gear,Filename,Athlete Weight,Bike Weight,Elapsed Time,Moving Time,Distance,Max Speed,Average Speed,Elevation Gain,Elevation Loss,Elevation Low,Elevation High,Max Grade,Average Grade,Average Positive Grade,Average Negative Grade,Max Cadence,Average Cadence,Max Heart Rate,Average Heart Rate,Max Watts,Average Watts,Calories,Max Temperature,Average Temperature,Relative Effort,Total Work,Number of Runs,Uphill Time,Downhill Time,Other Time,Perceived Exertion,Type,Start Time,Weighted Average Power,Power Count,Prefer Perceived Exertion,Perceived Relative Effort,Commute,Total Weight Lifted,From Upload,Grade Adjusted Distance,Weather Observation Time,Weather Condition,Weather Temperature,Apparent Temperature,Dewpoint,Humidity,Weather Pressure,Wind Speed,Wind Gust,Wind Bearing,Precipitation Intensity,Sunrise Time,Sunset Time,Moon Phase,Bike,Gear,Precipitation Probability,Precipitation Type,Cloud Cover,Weather Visibility,UV Index,Weather Ozone,Jump Count,Total Grit,Average Flow,Flagged,Average Elapsed Speed,Dirt Distance,Newly Explored Distance,Newly Explored Dirt Distance,Activity Count,Total Steps,Carbon Saved,Pool Length,Training Load,Intensity,Average Grade Adjusted Pace,Timer Time,Total Cycles,Media
;

// 0 - Activity ID
// 2 - Activity Name
// 3 - Activity Type
// 4 - Activity Description
// 5 - Elapsed Time [u32]
// 6 - Distance [f32]
// 11 - Activity Gear
// 12 - Filename
// 16 - Moving Time
// 17 - Distance [float]
// 18 - Max Speed [float]
// 19 - Average Speed [float]
// 20 - Elevation Gain [float]
// 21 - Elevation Loss [float]
// 36 - Average Temperature [float like]

// 0 - Activity ID
// 2 - Activity Name
// 3 - Activity Type
// 4 - Activity Description
// 11 - Activity Gear
// 12 - Filename
const CsvField = struct {
    idx: usize,
    name: []u8,
    type: type,
};

// const fields = [_]CsvField{.{.idx = 0, .name = }}

pub const Error = error{InvalidActivitiesCsv};

const Activity = struct {
    id: u64,
    name: ?[]const u8,
    kind: ?[]const u8,
    description: ?[]const u8,
    elapsed_time: u32,
    distance: u32,
    gear: ?[]const u8,
    filename: []const u8,
    moving_time: u32,
    max_speed: u32,
    avg_speed: u32,
    elev_gain: ?u32,
    elev_loss: ?u32,
    avg_temperature: ?i8,
};

fn printActivity(ac: *Activity) !void {
    try std.json.stringify(
        ac,
        .{ .whitespace = .indent_4 },
        std.io.getStdOut().writer(),
    );
}

fn process(a: mem.Allocator, csv_content: []const u8) !void {
    if (!mem.startsWith(u8, csv_content, activities_csv_header))
        return Error.InvalidActivitiesCsv;
    const csv = try activities_csv.parse(a, csv_content);
    defer csv.deinit();
    for (csv.records.items) |rec| {
        const ac = try activityFromCsvValues(rec.items);
        std.debug.print("{s}\n", .{ac.name orelse "UNKNOWN"});
    }
}

// test process {
//     const file = try std.fs.openFileAbsolute("/home/ihor/stuff/export_53360041/activities.csv", .{});
//     const bytes: []u8 = try file.readToEndAlloc(testing.allocator, (try file.stat()).size);
//     defer testing.allocator.free(bytes);
//     try process(testing.allocator, bytes);

//     try testing.expect(4 == 4);
// }

pub fn activityFromCsvValues(values: [][]const u8) !Activity {
    return .{
        .id = try fmt.parseInt(u64, values[0], 10),
        .name = csvStrToValue(values[2]),
        .kind = csvStrToValue(values[3]),
        .description = csvStrToValue(values[4]),
        .gear = csvStrToValue(values[11]),
        .filename = values[12],
        .moving_time = @intFromFloat(try fmt.parseFloat(f32, values[16])),
        .max_speed = @intFromFloat(try fmt.parseFloat(f32, values[18]) * 1_000),
        .avg_speed = @intFromFloat(try fmt.parseFloat(f32, values[19]) * 1_000),
        .elev_gain = if (values[20].len > 0) @intFromFloat(try fmt.parseFloat(f32, values[20])) else null,
        .elev_loss = if (values[21].len > 0) @intFromFloat(try fmt.parseFloat(f32, values[21])) else null,
        .avg_temperature = if (values[36].len > 0) @intFromFloat(try fmt.parseFloat(f32, values[36])) else null,
        .elapsed_time = try fmt.parseInt(u32, values[5], 10),
        .distance = @intFromFloat(try fmt.parseFloat(f32, values[17])),
    };
}

fn csvStrToValue(val: []const u8) ?[]const u8 {
    if (val.len == 0) return null;
    if (val.len >= 2 and val[0] == '"' and val[val.len - 1] == '"') {
        if (val.len == 2) return null;
        return val[1 .. val.len - 1];
    }
    return val;
}

const csv_test_content =
    \\Activity ID,Activity Date,Activity Name,Activity Type,Activity Description,Elapsed Time,Distance,Max Heart Rate,Relative Effort,Commute,Activity Private Note,Activity Gear,Filename,Athlete Weight,Bike Weight,Elapsed Time,Moving Time,Distance,Max Speed,Average Speed,Elevation Gain,Elevation Loss,Elevation Low,Elevation High,Max Grade,Average Grade,Average Positive Grade,Average Negative Grade,Max Cadence,Average Cadence,Max Heart Rate,Average Heart Rate,Max Watts,Average Watts,Calories,Max Temperature,Average Temperature,Relative Effort,Total Work,Number of Runs,Uphill Time,Downhill Time,Other Time,Perceived Exertion,Type,Start Time,Weighted Average Power,Power Count,Prefer Perceived Exertion,Perceived Relative Effort,Commute,Total Weight Lifted,From Upload,Grade Adjusted Distance,Weather Observation Time,Weather Condition,Weather Temperature,Apparent Temperature,Dewpoint,Humidity,Weather Pressure,Wind Speed,Wind Gust,Wind Bearing,Precipitation Intensity,Sunrise Time,Sunset Time,Moon Phase,Bike,Gear,Precipitation Probability,Precipitation Type,Cloud Cover,Weather Visibility,UV Index,Weather Ozone,Jump Count,Total Grit,Average Flow,Flagged,Average Elapsed Speed,Dirt Distance,Newly Explored Distance,Newly Explored Dirt Distance,Activity Count,Total Steps,Carbon Saved,Pool Length,Training Load,Intensity,Average Grade Adjusted Pace,Timer Time,Total Cycles,Media
    \\4163856655,"Oct 7, 2020, 2:43:11 PM",Evening chill,Ride,"",5601,18.96,,,false,,Pathfinder,activities/4163856655.gpx,,,5601.0,4567.0,18962.80078125,10.399999618530273,4.152134895324707,109.99222564697266,113.69200134277344,115.4000015258789,156.0,9.300000190734863,-0.019511885941028595,,,,,,,,,,,,,,,,,,,,,,,0.0,,0.0,,1.0,,,,,,,,,,,,,,,,8939761.0,,,,,,,,,,,,,,,,,,,,,,,,,""
    \\4237621525,"Oct 24, 2020, 1:05:04 PM",Test,Ride,"",9487,19.79,,,false,,Topstone,activities/4237621525.gpx,,,9487.0,6901.0,19789.80078125,9.100000381469727,2.867671251296997,200.5626678466797,264.9630126953125,112.69999694824219,194.39999389648438,40.70000076293945,-0.32542017102241516,,,,,,,,,,,,,,,,,,,,,,,0.0,,0.0,,1.0,,,,,,,,,,,,,,,,8939781.0,,,,,,,,,,,,,,,,,,,,,,,,,""
;
