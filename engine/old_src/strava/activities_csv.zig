const std = @import("std");
const mem = std.mem;
const testing = std.testing;
const ArrayList = std.ArrayList;

const strava_csv_header = "Activity ID,Activity Date,Activity Name,Activity Type,Activity Description,Elapsed Time,Distance,Max Heart Rate,Relative Effort,Commute,Activity Private Note,Activity Gear,Filename,Athlete Weight,Bike Weight,Elapsed Time,Moving Time,Distance,Max Speed,Average Speed,Elevation Gain,Elevation Loss,Elevation Low,Elevation High,Max Grade,Average Grade,Average Positive Grade,Average Negative Grade,Max Cadence,Average Cadence,Max Heart Rate,Average Heart Rate,Max Watts,Average Watts,Calories,Max Temperature,Average Temperature,Relative Effort,Total Work,Number of Runs,Uphill Time,Downhill Time,Other Time,Perceived Exertion,Type,Start Time,Weighted Average Power,Power Count,Prefer Perceived Exertion,Perceived Relative Effort,Commute,Total Weight Lifted,From Upload,Grade Adjusted Distance,Weather Observation Time,Weather Condition,Weather Temperature,Apparent Temperature,Dewpoint,Humidity,Weather Pressure,Wind Speed,Wind Gust,Wind Bearing,Precipitation Intensity,Sunrise Time,Sunset Time,Moon Phase,Bike,Gear,Precipitation Probability,Precipitation Type,Cloud Cover,Weather Visibility,UV Index,Weather Ozone,Jump Count,Total Grit,Average Flow,Flagged,Average Elapsed Speed,Dirt Distance,Newly Explored Distance,Newly Explored Dirt Distance,Activity Count,Total Steps,Carbon Saved,Pool Length,Training Load,Intensity,Average Grade Adjusted Pace,Timer Time,Total Cycles,Media";

pub const Csv = struct {
    header: ArrayList([]const u8),
    records: ArrayList(ArrayList([]const u8)),
    allocator: mem.Allocator,

    pub fn init(a: mem.Allocator) Csv {
        return .{
            .header = ArrayList([]const u8).init(a),
            .records = ArrayList(ArrayList([]const u8)).init(a),
            .allocator = a,
        };
    }

    pub fn deinit(csv: *const Csv) void {
        csv.header.deinit();
        for (csv.records.items) |rec| {
            rec.deinit();
        }
        csv.records.deinit();
    }
};

pub fn parse(a: mem.Allocator, csv: []const u8) !Csv {
    var result = Csv.init(a);
    var pos: usize = 0;
    while (true) {
        const idx = readValue(csv[pos..]);
        try result.header.append(csv[pos .. pos + idx]);
        pos += idx + 1;
        if (pos < csv.len and csv[pos - 1] == '\n')
            break;
    }
    const every_nth = 200;
    var records_count: usize = 0;
    while (pos < csv.len) {
        const skip = records_count % every_nth != 0;
        var record = ArrayList([]const u8).init(a);
        for (0..result.header.items.len) |_| {
            const idx = readValue(csv[pos..]);
            if (!skip)
                try record.append(csv[pos .. pos + idx]);

            pos += idx + 1;
        }
        records_count += 1;
        if (!skip)
            try result.records.append(record);
    }
    return result;
}

// test parse {
//     const path = "/home/ihor/stuff/export_53360041/activities.csv";
//     const csv_content = try fileAsBytes(testing.allocator, path);
//     defer testing.allocator.free(csv_content);

//     const csv = try parse(testing.allocator, csv_content);
//     defer csv.deinit();

//     std.debug.print("activities: {d}\n", .{csv.records.items.len});
//     for (600..csv.records.items.len) |i| {
//         const rec = csv.records.items[i];
//         std.debug.print("{s}\n", .{rec.items[2]});
//     }

//     try testing.expect(4 == 4);
// }

// test parseCsv {
//     const csv = try parseCsv(testing.allocator, test_csv);
//     defer csv.deinit();
//     std.debug.print("header len = {d}\n", .{csv.header.items.len});
//     std.debug.print("records count = {d}\n", .{csv.records.items.len});
//     std.debug.print("header len = {d}: {s} ... {s}\n", .{
//         csv.header.items.len,
//         csv.header.items[0],
//         csv.header.items[csv.header.items.len - 1],
//     });
//     for (csv.records.items) |rec| {
//         std.debug.print("======================================\n", .{});
//         std.debug.print("{s} {s} {s} {s}\n{s}\n", .{
//             rec.items[0],
//             rec.items[1],
//             rec.items[2],
//             rec.items[3],
//             rec.items[4],
//         });
//         // std.debug.print("{d}: len={d}: [{s}] ... [{s}]\n", .{
//         //     i,
//         //     rec.items.len,
//         //     rec.items[0],
//         //     rec.items[rec.items.len - 1],
//         // });
//     }
//     // std.debug.print("{s}\n", .{csv.records.items[csv.records.items.len - 1].items[0]});

//     // for (0..5) |i| {
//     //     std.debug.print("{s}\n", .{csv.header.items[i]});
//     // }

//     try testing.expect(4 == 4);
// }

fn readValue(csv: []const u8) usize {
    var q = false;
    for (0..csv.len) |i| {
        const c = csv[i];
        if (c == '"') {
            q = !q;
        }
        if (!q and (c == ',' or c == '\n')) {
            return i;
        }
    }
    return csv.len;
}

fn fileAsBytes(alloc: std.mem.Allocator, file_path: []const u8) ![]u8 {
    const file = try std.fs.openFileAbsolute(file_path, .{});
    defer file.close();

    const stat = try file.stat();
    const buf: []u8 = try file.readToEndAlloc(alloc, stat.size);
    return buf;
}

const test_csv =
    \\9095753471,"May 18, 2023, 1:14:30 PM",Afternoon Ride,Ride,"",15660,70.03,,,false,,Topstone,activities/9757461867.fit.gz,,9.5,15660.0,11812.0,70031.8828125,13.095703125,5.928875923156738,431.0,411.0,-133.39999389648438,-17.200000762939453,41.81816864013672,0.03312777355313301,,,,,,,,170.05348205566406,1150.0,,24.0,,,,,,,,,,,,0.0,,0.0,,1.0,,1684414848.0,1.0,25.549999237060547,24.450000762939453,7.820000171661377,0.3199999928474426,1018.0499877929688,4.139999866485596,8.649999618530273,73.0,0.0,1684375552.0,1684431104.0,0.0,8939781.0,,0.0,1.0,0.3499999940395355,31202.599609375,4.0,,,,,0.0,4.472023010253906,8732.0,,,,,,,,,,,,""
    \\9108413812,"May 19, 2023, 11:59:20 PM",Insomnia,Ride,"DNF BRM 400 / Горбаті гори
    \\Sleepless 500km fail
    \\
    \\Не вийшло поспать перед виїздом, їхати без сну бажання не було, але все-таки поїхав. Думав що може в процесі з'явиться настрій, а якщо ні — то просто поїду додому найкоротшим шляхом. Так і вийшло: проїхавши 280км, поїхав з Миронівки в Смілу — ще й встиг на електричку.",63440,385.03,,,false,"",Topstone,activities/9770837028.fit.gz,,9.5,63440.0,53509.0,385036.46875,13.796875,7.195733070373535,2118.0,2142.0,-175.1999969482422,-33.79999923706055,35.656288146972656,-0.005246255546808243,,,,,,,,212.78758239746094,6365.0,,20.0,,,,,,,,,,,,0.0,,0.0,,1.0,,1684537216.0,1.0,15.779999732971191,15.319999694824219,10.619999885559082,0.7099999785423279,1020.8200073242188,2.859999895095825,5.989999771118164,16.0,0.0,1684548224.0,1684604032.0,0.0,8939781.0,,0.0,1.0,0.07000000029802322,29850.509765625,0.0,,,,,0.0,6.069301128387451,1828.800048828125,,,,,,,,,,,,""
    \\9115179227,"May 21, 2023, 10:28:06 AM",десант в мамаїв яр & mtb chill,Ride,"Фотографував яр і пам'ятник біля нього, причепилась якась бабця — питала хто я такий, що я тут роблю і що фотографую, сказав що просто катаюсь і фотографую природу. В кінці нашого діалогу коли аргументи закінчились сказала ""Нам і так важко, а ти ще гірше робиш""",27548,99.93,,,false,,Pathfinder,activities/9778048252.fit.gz,,9.5,27548.0,20762.0,99934.640625,13.164013862609863,4.8133440017700195,674.0,751.0,-102.5999984741211,10.199999809265137,33.20869445800781,-0.07404839992523193,,,,,,,,174.93052673339844,1964.0,,23.0,,,,,,,,,,,,0.0,,0.0,,1.0,,1684663168.0,2.0,20.290000915527344,19.579999923706055,9.4399995803833,0.5,1018.510009765625,5.860000133514404,11.199999809265137,40.0,0.0,1684634496.0,1684690304.0,0.125,8939761.0,,0.0,1.0,0.5199999809265137,29553.640625,5.0,,,,,0.0,3.627655029296875,8240.099609375,,,,,,,,,,,,media/4cccfe0e-f089-4197-8548-8f61eaa982d5.jpg|media/deb061da-2dbc-49d0-99b1-d669022044c6.jpg
    \\9126220748,"May 23, 2023, 1:10:00 PM",Countryside ,Ride,"",14823,76.50,,,false,,Topstone,activities/9789877699.fit.gz,,9.5,14823.0,12166.0,76500.5234375,13.603906631469727,6.288058757781982,674.0,669.0,-52.400001525878906,64.0,30.795591354370117,0.007320214528590441,,,,,,,,195.6552734375,1390.0,,21.0,,,,,,,,,,,,0.0,,0.0,,1.0,,1684846848.0,2.0,22.010000228881836,21.68000030517578,12.210000038146973,0.5400000214576721,1012.1400146484375,3.7799999713897705,7.579999923706055,41.0,0.0,1684807168.0,1684863360.0,0.125,8939781.0,,0.0,1.0,0.6100000143051147,22785.4609375,3.0,,,,,0.0,5.160933971405029,17178.30078125,,,,,,,,,,,,media/92a65bc1-16b2-4bf8-9042-2173681fda54.jpg|media/6dee3f7e-9962-4eff-933e-4de6fc9b5b6a.jpg
;
