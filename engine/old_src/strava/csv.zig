const std = @import("std");
const fs = std.fs;
const testing = std.testing;
const mem = std.mem;
const ArrayList = std.ArrayList;

const Result = struct {
    header: ArrayList([]const u8),
    values: ArrayList([]const u8),

    pub fn deinit(result: *const Result, allocator: mem.Allocator) void {
        for (result.header.items) |item| {
            allocator.free(item);
        }
        result.header.deinit();
        for (result.values.items) |item| {
            allocator.free(item);
        }
        result.values.deinit();
    }
};

fn parseCsvFile(a: mem.Allocator, file: fs.File) !Result {
    const reader = file.reader();
    const header_line = try reader.readUntilDelimiterAlloc(a, '\n', std.math.maxInt(u32));
    defer a.free(header_line);
    const header = try parseRecord(a, header_line);

    for (0..264) |_| {
        try reader.skipUntilDelimiterOrEof('\n');
    }

    const values = try readValuesCount(a, reader, header.items.len);

    // const line = try reader.readUntilDelimiterAlloc(a, '\n', std.math.maxInt(u32));
    // defer a.free(line);
    // const values = try parseRecord(a, line);
    // if (values.items.len < header.items.len) {}

    return .{
        .header = header,
        .values = values,
    };
}

test parseCsvFile {
    const path = "/home/ihor/stuff/export_53360041/activities.csv";
    const file = try fs.openFileAbsolute(path, .{});
    defer file.close();

    const result = try parseCsvFile(testing.allocator, file);
    defer result.deinit(testing.allocator);

    try testing.expect(result.header.items.len == 94);
    // try testing.expect(result.values.items.len == result.header.items.len);
    try testing.expect(mem.eql(u8, result.header.items[0], "Activity ID"));
    try testing.expect(mem.eql(u8, result.header.items[1], "Activity Date"));
    try testing.expect(mem.eql(u8, result.header.items[2], "Activity Name"));
    // try testing.expect(mem.eql(u8, result.values.items[0], "4163856655"));
    // try testing.expect(mem.eql(u8, result.values.items[1], "\"Oct 7, 2020, 2:43:11 PM\""));
    // try testing.expect(mem.eql(u8, result.values.items[2], "Evening chill"));
    for (0..5) |i| {
        std.debug.print("{s}: {s}\n", .{
            result.header.items[i],
            result.values.items[i],
        });
    }
}

fn readValuesCount(
    a: mem.Allocator,
    reader: anytype,
    count: usize,
) !ArrayList([]const u8) {
    var result = try ArrayList([]const u8).initCapacity(a, count);
    var q = false;
    // var v: ?[]u8 = null;
    while (result.items.len < count) {
        const line = try reader.readUntilDelimiterAlloc(a, '\n', std.math.maxInt(u32));
        defer a.free(line);
        var from: usize = 0;
        const len = line.len;
        for (0..line.len) |i| {
            const c = line[i];
            if (i == len - 1) {
                if (c == '"') q = !q;
                const val = try a.alloc(u8, len - from);
                @memcpy(val, line[from..len]);
                if (q) {
                    const last = result.pop();
                    std.debug.print("POP: {s}\n", .{last});
                    const concat = try a.alloc(u8, last.len + val.len);
                    @memcpy(concat[0..last.len], last);
                    @memcpy(concat[last.len..], val);
                    a.free(val);
                    result.items[result.items.len - 1] = concat;
                } else {
                    try result.append(val);
                }
                break;
            }
            if (c == '"') {
                q = !q;
            }
            if (c == ',' and !q) {
                const val = try a.alloc(u8, i - from);
                @memcpy(val, line[from..i]);
                // std.debug.print("VAL: {s}\n", .{val});
                try result.append(val);
                from = i + 1;
            }
        }
    }
    return result;
}

fn readValue(csv: []const u8, in_quote: bool) usize {
    // var values = ArrayList([]const u8).init(a);
    // var from: usize = 0;
    // const len = record.len;
    // var q = false;
    var q = in_quote;
    for (0..csv.len) |i| {
        // if (i == csv.len - 1) {
        //     // const val = try a.alloc(u8, len - from);
        //     // @memcpy(val, record[from..len]);
        //     // try values.append(val);
        //     if (q) return null;
        //     return i;
        // }
        const c = csv[i];
        if (c == '"') {
            q = !q;
        }
        if (c == ',' and !q) {
            // const val = try a.alloc(u8, i - from);
            // @memcpy(val, record[from..i]);
            // try values.append(val);
            // from = i + 1;
            return i;
        }
    }
    // if (q) return null;
    return csv.len;
}

test readValue {
    const csv =
        // \\9095753471,"May 18, 2023, 1:14:30 PM",Afternoon Ride,Ride,"",15660,70.03,,,false,,Topstone,activities/9757461867.fit.gz,,9.5,15660.0,11812.0,70031.8828125,13.095703125,5.928875923156738,431.0,411.0,-133.39999389648438,-17.200000762939453,41.81816864013672,0.03312777355313301,,,,,,,,170.05348205566406,1150.0,,24.0,,,,,,,,,,,,0.0,,0.0,,1.0,,1684414848.0,1.0,25.549999237060547,24.450000762939453,7.820000171661377,0.3199999928474426,1018.0499877929688,4.139999866485596,8.649999618530273,73.0,0.0,1684375552.0,1684431104.0,0.0,8939781.0,,0.0,1.0,0.3499999940395355,31202.599609375,4.0,,,,,0.0,4.472023010253906,8732.0,,,,,,,,,,,,""
        \\9108413812,"May 19, 2023, 11:59:20 PM",Insomnia,Ride,"DNF BRM 400 / Горбаті гори
        \\Sleepless 500km fail
        \\
        \\Не вийшло поспать перед виїздом, їхати без сну бажання не було, але все-таки поїхав. Думав що може в процесі з'явиться настрій, а якщо ні — то просто поїду додому найкоротшим шляхом. Так і вийшло: проїхавши 280км, поїхав з Миронівки в Смілу — ще й встиг на електричку.",63440,385.03,,,false,"",Topstone,activities/9770837028.fit.gz,,9.5,63440.0,53509.0,385036.46875,13.796875,7.195733070373535,2118.0,2142.0,-175.1999969482422,-33.79999923706055,35.656288146972656,-0.005246255546808243,,,,,,,,212.78758239746094,6365.0,,20.0,,,,,,,,,,,,0.0,,0.0,,1.0,,1684537216.0,1.0,15.779999732971191,15.319999694824219,10.619999885559082,0.7099999785423279,1020.8200073242188,2.859999895095825,5.989999771118164,16.0,0.0,1684548224.0,1684604032.0,0.0,8939781.0,,0.0,1.0,0.07000000029802322,29850.509765625,0.0,,,,,0.0,6.069301128387451,1828.800048828125,,,,,,,,,,,,""
    ;
    var from: usize = 0;
    for (0..15) |_| {
        const idx = readValue(csv[from..], false);
        const val = csv[from .. from + idx];
        std.debug.print("{s}\n", .{val});
        from += idx + 1;
    }

    try testing.expect(4 == 4);
}

// test readValue {
//     const csv =
//         \\9089078333,"May 17, 2023, 1:56:12 PM",mtb ride,Ride,"",11311,"hello
//         \\world",123
//     ;
//     var it = std.mem.split(u8, csv, '\n');
//     // const csv = "9089078333,\"May 17, 2023, 1:56:12 PM\",mtb ride,Ride,\"\",11311";
//     var list = ArrayList([]const u8).init(testing.allocator);
//     defer list.deinit();
//     var from: usize = 0;
//     var line = it.next();
//     for (0..8) |_| {
//         const to_idx = readValue(csv[from..], false);
//         if (to_idx == null) {

//         }
//         const str = csv[from .. from + to_idx.?];
//         from += to_idx.? + 1;
//         try list.append(str);
//         std.debug.print("{s}\n", .{str});
//     }
//     // printList(list);
//     try testing.expect(4 == 4);
// }

fn parseRecord(a: mem.Allocator, record: []const u8) !ArrayList([]const u8) {
    var values = ArrayList([]const u8).init(a);
    var from: usize = 0;
    const len = record.len;
    var q = false;
    for (0..record.len) |i| {
        if (i == len - 1) {
            const val = try a.alloc(u8, len - from);
            @memcpy(val, record[from..len]);
            try values.append(val);
            break;
        }
        const c = record[i];
        if (c == '"') {
            q = !q;
        }
        if (c == ',' and !q) {
            const val = try a.alloc(u8, i - from);
            @memcpy(val, record[from..i]);
            try values.append(val);
            from = i + 1;
        }
    }
    return values;
}

test parseRecord {
    // const csv = "9363646543,\"Jun 30, 2023, 12:20:56 PM\",🌤️⛅🌧️☁️⛅,Ride,🟩🟩🟩🟩🟩🟩🟩🟩🟩,18504,72.58,,,false,,Topstone,activities/10043595029.fit.gz,,9.5,18504.0,12976.0,72585.15625,12.665624618530273,5.5938005447387695,505.1435546875,524.0,119.0999984741211";
    const csv = "Activity ID,Activity Date,Activity Name,Activity Type,Activity Description,Elapsed Time,Distance,Max Heart Rate,Relative Effort,Commute,Activity Private Note,Activity Gear,Filename,Athlete Weight,Bike Weight,Elapsed Time,Moving Time,Distance,Max Speed,Average Speed,Elevation Gain,Elevation Loss,Elevation Low,Elevation High,Max Grade,Average Grade,Average Positive Grade,Average Negative Grade,Max Cadence,Average Cadence,Max Heart Rate,Average Heart Rate,Max Watts,Average Watts,Calories,Max Temperature,Average Temperature,Relative Effort,Total Work,Number of Runs,Uphill Time,Downhill Time,Other Time,Perceived Exertion,Type,Start Time,Weighted Average Power,Power Count,Prefer Perceived Exertion,Perceived Relative Effort,Commute,Total Weight Lifted,From Upload,Grade Adjusted Distance,Weather Observation Time,Weather Condition,Weather Temperature,Apparent Temperature,Dewpoint,Humidity,Weather Pressure,Wind Speed,Wind Gust,Wind Bearing,Precipitation Intensity,Sunrise Time,Sunset Time,Moon Phase,Bike,Gear,Precipitation Probability,Precipitation Type,Cloud Cover,Weather Visibility,UV Index,Weather Ozone,Jump Count,Total Grit,Average Flow,Flagged,Average Elapsed Speed,Dirt Distance,Newly Explored Distance,Newly Explored Dirt Distance,Activity Count,Total Steps,Carbon Saved,Pool Length,Training Load,Intensity,Average Grade Adjusted Pace,Timer Time,Total Cycles,Media";

    const list = try parseRecord(testing.allocator, csv);
    defer list.deinit();
    printList(list);

    // const res = [_][]const u8{ "one", "two", "three" };
    try testing.expect(4 == 4);

    // try testing.expect(list.items.len == res.len);
    // for (0..list.items.len) |i| {
    //     try testing.expect(mem.eql(u8, list.items[i], res[i]));
    // }
}

fn printList(list: ArrayList([]const u8)) void {
    std.debug.print("{d}\n", .{list.items.len});
    std.debug.print("=======================\n", .{});
    for (list.items) |item| {
        std.debug.print("{s}\n", .{item});
    }
    std.debug.print("=======================\n", .{});
}
