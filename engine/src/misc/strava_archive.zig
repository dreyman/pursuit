const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const fs = std.fs;

const csv = @import("csv.zig");

pub const Error = error{InvalidActivityFieldValue};

const RecordValIdx = struct {
    pub const id = 0;
    pub const name = 2;
    pub const kind = 3;
    pub const description = 4;
    pub const gear = 11;
    pub const filename = 12;
    pub const elapsed_time = 15;
    pub const moving_time = 16;
    pub const distance = 17;
    pub const max_speed = 18;
    pub const avg_speed = 19;
    pub const elevation_gain = 20;
    pub const elevation_loss = 21;
};

pub const Activity = struct {
    alloc: Allocator,
    id: ID,
    name: []u8,
    kind: []u8,
    description: []u8,
    gear: []u8,
    file: []u8,
    elapsed_time: u32,
    moving_time: u32,
    distance: u32,
    max_speed: u32,
    avg_speed: u32,
    elevation_gain: u32,
    elevation_loss: u32,

    start_time: u32 = 0,

    pub const ID = u64;

    pub fn createFromList(
        alloc: Allocator,
        rec: [][]const u8,
    ) !*Activity {
        const a = try alloc.create(Activity);
        errdefer alloc.destroy(a);

        const id = try std.fmt.parseInt(Activity.ID, rec[RecordValIdx.id], 10);

        const name = try alloc.dupe(u8, rec[RecordValIdx.name]);
        errdefer alloc.free(name);

        const kind = try alloc.dupe(u8, rec[RecordValIdx.kind]);
        errdefer alloc.free(kind);

        const descr = try alloc.dupe(u8, rec[RecordValIdx.description]);
        errdefer alloc.free(descr);

        const gear = try alloc.dupe(u8, rec[RecordValIdx.gear]);
        errdefer alloc.free(gear);

        const filename = try alloc.dupe(u8, rec[RecordValIdx.filename]);
        errdefer alloc.free(filename);

        a.* = .{
            .alloc = alloc,
            .id = id,
            .name = name,
            .kind = kind,
            .description = descr,
            .gear = gear,
            .file = filename,
            .elapsed_time = @intFromFloat(try std.fmt.parseFloat(f64, rec[RecordValIdx.elapsed_time])),
            .moving_time = @intFromFloat(try std.fmt.parseFloat(f64, rec[RecordValIdx.moving_time])),
            .distance = @intFromFloat(try std.fmt.parseFloat(f64, rec[RecordValIdx.distance])),
            .max_speed = convertSpeedMsToMh(try std.fmt.parseFloat(f64, rec[RecordValIdx.max_speed])),
            .avg_speed = convertSpeedMsToMh(try std.fmt.parseFloat(f64, rec[RecordValIdx.avg_speed])),
            .elevation_gain = @intFromFloat(try std.fmt.parseFloat(f64, rec[RecordValIdx.elevation_gain])),
            .elevation_loss = @intFromFloat(try std.fmt.parseFloat(f64, rec[RecordValIdx.elevation_loss])),
        };
        return a;
    }

    pub fn destroy(ac: *Activity) void {
        ac.alloc.free(ac.name);
        ac.alloc.free(ac.kind);
        ac.alloc.free(ac.description);
        ac.alloc.free(ac.gear);
        ac.alloc.free(ac.file);
        ac.alloc.destroy(ac);
    }
};

pub fn getActivities(
    alloc: Allocator,
    archive_dir_path: []const u8,
) !ArrayList(*Activity) {
    var archive_dir = try fs.cwd().openDir(archive_dir_path, .{});
    defer archive_dir.close();
    const csv_content = try archive_dir.readFileAlloc(
        alloc,
        "activities.csv",
        100_000_000,
    );
    const activities_csv = try csv.parse(alloc, csv_content);
    defer activities_csv.destroy();

    var acs = ArrayList(*Activity).init(alloc);
    errdefer {
        for (acs.items) |ac| ac.destroy();
        acs.deinit();
    }
    for (activities_csv.records.items) |rec| {
        try acs.append(try Activity.createFromList(alloc, rec.items));
    }
    return acs;
}

fn convertSpeedMsToMh(ms: f64) u32 {
    return @intFromFloat((ms * 3.6) * 1_000);
}

test "Activity.createFromList" {
    const t = std.testing;
    const alloc = t.allocator;
    const mem = std.mem;
    const csv_str =
        \\Activity ID,Activity Date,Activity Name,Activity Type,Activity Description,Elapsed Time,Distance,Max Heart Rate,Relative Effort,Commute,Activity Private Note,Activity Gear,Filename,Athlete Weight,Bike Weight,Elapsed Time,Moving Time,Distance,Max Speed,Average Speed,Elevation Gain,Elevation Loss,Elevation Low,Elevation High,Max Grade,Average Grade,Average Positive Grade,Average Negative Grade,Max Cadence,Average Cadence,Max Heart Rate,Average Heart Rate,Max Watts,Average Watts,Calories,Max Temperature,Average Temperature,Relative Effort,Total Work,Number of Runs,Uphill Time,Downhill Time,Other Time,Perceived Exertion,Type,Start Time,Weighted Average Power,Power Count,Prefer Perceived Exertion,Perceived Relative Effort,Commute,Total Weight Lifted,From Upload,Grade Adjusted Distance,Weather Observation Time,Weather Condition,Weather Temperature,Apparent Temperature,Dewpoint,Humidity,Weather Pressure,Wind Speed,Wind Gust,Wind Bearing,Precipitation Intensity,Sunrise Time,Sunset Time,Moon Phase,Bike,Gear,Precipitation Probability,Precipitation Type,Cloud Cover,Weather Visibility,UV Index,Weather Ozone,Jump Count,Total Grit,Average Flow,Flagged,Average Elapsed Speed,Dirt Distance,Newly Explored Distance,Newly Explored Dirt Distance,Activity Count,Total Steps,Carbon Saved,Pool Length,Training Load,Intensity,Average Grade Adjusted Pace,Timer Time,Total Cycles,Media
        \\9041865559,"May 9, 2023, 10:09:29 AM",🎵🎶,Ride,200km ride,34021,200.10,,,false,,Topstone,activities/9700428229.fit.gz,,9.5,34021.0,28586.0,200100.015625,14.35791015625,6.999930381774902,1433.0,1424.0,-154.8000030517578,-47.0,40.235755920410156,0.00569714792072773,,,,,,,,202.92457580566406,3357.0,,13.0,,,,,,,,,,,,0.0,,0.0,,1.0,,1683626368.0,3.0,13.390000343322754,12.199999809265137,0.23999999463558197,0.4099999964237213,1025.6400146484375,4.949999809265137,10.3100004196167,52.0,0.0,1683598720.0,1683652736.0,0.625,8939781.0,,0.0,1.0,0.9200000166893005,28913.130859375,3.0,,,,,0.0,5.881661891937256,714.2999877929688,,,,,,,,,,,,media/27d6f32b-bc1f-42be-9053-5de8610573f2.jpg|media/87f23c69-1dfc-4ed1-b0e6-0ce77e306292.jpg|media/93529523-5e25-4747-a628-5d119dd4cf46.jpg
    ;
    var activities_csv = try csv.parse(alloc, csv_str);
    defer activities_csv.destroy();

    var ac = try Activity.createFromList(alloc, activities_csv.records.items[0].items);
    defer ac.destroy();

    try t.expect(ac.id == 9041865559);
    try t.expect(mem.eql(u8, ac.name, "🎵🎶"));
    try t.expect(mem.eql(u8, ac.kind, "Ride"));
    try t.expect(mem.eql(u8, ac.description, "200km ride"));
    try t.expect(mem.eql(u8, ac.gear, "Topstone"));
    try t.expect(mem.eql(u8, ac.file, "activities/9700428229.fit.gz"));
    try t.expect(ac.elapsed_time == 34021);
    try t.expect(ac.moving_time == 28586);
    try t.expect(ac.distance == 200100);
    try t.expect(ac.max_speed == 51688);
    try t.expect(ac.avg_speed == 25199);
    try t.expect(ac.elevation_gain == 1433);
    try t.expect(ac.elevation_loss == 1424);
}
