const std = @import("std");
const mem = std.mem;
const assert = std.debug.assert;
const testing = std.testing;
const fmt = std.fmt;

const indexOf = mem.indexOfPosLinear;

pub const Error = error{ InvalidGpx, InvalidGpxTime };

pub const CompactGpx = struct {
    lat: []f64,
    lon: []f64,
    time: []u32,
    ele: ?[]i32,
    allocator: mem.Allocator,

    // pub fn init(allocator: mem.Allocator, size: usize) !CompactGpx {
    //     return .{
    //         .lat = try allocator.alloc(f64, size),
    //         .lon = try allocator.alloc(f64, size),
    //         .time = try allocator.alloc(u32, size),
    //         .ele = try allocator.alloc(i32, size),
    //         .allocator = allocator,
    //     };
    // }
};

pub const Gpx = struct {
    name: []const u8,
    type: []const u8,
    track: std.ArrayList(Trkpt),

    pub fn init(allocator: mem.Allocator) Gpx {
        return .{
            .name = undefined,
            .type = undefined,
            .track = std.ArrayList(Trkpt).init(allocator),
        };
    }

    pub fn deinit(gpx: *const Gpx) void {
        gpx.track.deinit();
    }

    pub const Trkpt = struct {
        lat: f64,
        lon: f64,
        ele: f16, // fixme change to i32 or i16 or u16?
        time: u32,

        pub const tagname = "trkpt";
    };
};

pub fn parse(a: mem.Allocator, gpx: []const u8) !Gpx {
    var result = Gpx.init(a);
    errdefer result.deinit();

    result.name = try tagContent(gpx, "name");
    result.type = try tagContent(gpx, "type");

    var pos: usize = 0;
    while (true) {
        const idx, const trkpt = try tagAndIndex(gpx[pos..], Gpx.Trkpt.tagname) orelse
            return result;
        assert(trkpt.len >= 2 * Gpx.Trkpt.tagname.len + "<></>".len);
        const lat = try attr(trkpt, "lat");
        const lon = try attr(trkpt, "lon");
        const ele = try tagContent(trkpt, "ele");
        const time = try tagContent(trkpt, "time");

        try result.track.append(.{
            .lat = fmt.parseFloat(f64, lat) catch return Error.InvalidGpx,
            .lon = fmt.parseFloat(f64, lon) catch return Error.InvalidGpx,
            .ele = fmt.parseFloat(f16, ele) catch return Error.InvalidGpx,
            .time = timeStrToTimestamp(time) catch return Error.InvalidGpxTime,
        });

        pos += idx + trkpt.len;
    }
}

test parse {
    const t = testing;
    const gpx_content =
        \\<metadata>
        \\  <time>2022-01-07T09:19:53Z</time>
        \\</metadata>
        \\<trk>
        \\  <name>Testing 🏝️</name>
        \\  <type>cycling</type>
        \\  <trkseg>
        \\      <trkpt lat="48.9667190" lon="32.2284060">
        \\          <ele>126.0</ele>
        \\          <time>2022-01-07T09:19:53Z</time>
        \\      </trkpt>
        \\      <trkpt lat="48.9667190" lon="32.2284070">
        \\          <ele>126.0</ele>
        \\          <time>2022-01-07T09:19:54Z</time>
        \\      </trkpt>
        \\  </trgseg>
        \\</trk>
    ;
    const gpx = try parse(t.allocator, gpx_content);
    defer gpx.deinit();

    try t.expect(mem.eql(u8, gpx.name, "Testing 🏝️"));
    try t.expect(mem.eql(u8, gpx.type, "cycling"));
    try t.expect(gpx.track.items.len == 2);
    try t.expectError(Error.InvalidGpx, parse(t.allocator, gpx_content[0 .. gpx_content.len / 2]));
}

pub fn tagAndIndex(
    gpx: []const u8,
    comptime tag_name: []const u8,
) !?struct { usize, []const u8 } {
    const from = indexOf(u8, gpx, 0, "<" ++ tag_name) orelse
        return null;
    const closing_tag = "</" ++ tag_name ++ ">";
    const to = indexOf(u8, gpx, from + 1, closing_tag) orelse
        return Error.InvalidGpx;
    return .{ from, gpx[from .. to + closing_tag.len] };
}

pub fn tag(gpx: []const u8, comptime tag_name: []const u8) !?[]const u8 {
    _, const tag_str = try tagAndIndex(gpx, tag_name) orelse return Error.InvalidGpx;
    return tag_str;
}

test tag {
    const gpx =
        \\<trkpt lat="48.9667130" lon="32.2284080">
        \\  <ele>126.0</ele>
        \\  <time>2022-01-07T09:19:57Z</time>
        \\  <foo attr1="val">hello</foo>
        \\</trkpt>
    ;

    const ele = try tag(gpx, "ele");
    const time = try tag(gpx, "time");
    const foo = try tag(gpx, "foo");

    try testing.expect(mem.eql(u8, ele.?, "<ele>126.0</ele>"));
    try testing.expect(mem.eql(u8, time.?, "<time>2022-01-07T09:19:57Z</time>"));
    try testing.expect(mem.eql(u8, foo.?, "<foo attr1=\"val\">hello</foo>"));
    try testing.expectError(Error.InvalidGpx, tagContent("missingtag", gpx));
}

pub fn tagContent(gpx: []const u8, comptime tag_name: []const u8) ![]const u8 {
    const from = indexOf(u8, gpx, 0, "<" ++ tag_name) orelse return Error.InvalidGpx;
    const content_idx = (indexOf(u8, gpx, from, ">") orelse return Error.InvalidGpx) + 1;
    const closing_tag = "</" ++ tag_name ++ ">";
    const to = indexOf(u8, gpx, from + 1, closing_tag) orelse return Error.InvalidGpx;
    return gpx[content_idx..to];
}

test tagContent {
    const gpx =
        \\<trkpt lat="48.9667130" lon="32.2284080">
        \\<ele>126.0</ele>
        \\<time>2022-01-07T09:19:57Z</time>
        \\</trkpt>
    ;

    const ele = try tagContent(gpx, "ele");
    const time = try tagContent(gpx, "time");

    try testing.expect(mem.eql(u8, ele, "126.0"));
    try testing.expect(mem.eql(u8, time, "2022-01-07T09:19:57Z"));
    try testing.expectError(Error.InvalidGpx, tagContent("missingtag", gpx));
    try testing.expectError(Error.InvalidGpx, tagContent("<noclosingtag>content", "noclosingtag"));
}

pub fn attr(gpx: []const u8, attr_name: []const u8) ![]const u8 {
    var from = indexOf(u8, gpx, 0, attr_name) orelse return Error.InvalidGpx;
    from += attr_name.len + "=\"".len;
    const to = indexOf(u8, gpx, from + 1, "\"") orelse return Error.InvalidGpx;
    return gpx[from..to];
}

test attr {
    const gpx = "<trkpt lat=\"48.9667130\" lon=\"32.2284080\" foo=\"bar\">";

    const lon = try attr(gpx, "lon");
    const lat = try attr(gpx, "lat");
    const foo = try attr(gpx, "foo");

    try testing.expect(mem.eql(u8, lat, "48.9667130"));
    try testing.expect(mem.eql(u8, lon, "32.2284080"));
    try testing.expect(mem.eql(u8, foo, "bar"));
    try testing.expectError(Error.InvalidGpx, attr("missing", gpx));
    try testing.expectError(Error.InvalidGpx, attr("<tag some=\"val  ", "some"));
}

const daysToMonth = [_]u9{ 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365 };
pub const time_format = "yyyy-mm-ddThh:mm:ssZ";
const epoch = std.time.epoch;
const parseUint = std.fmt.parseUnsigned;
const isLeap = epoch.isLeapYear;
const seconds_in_day = 86_400;

pub fn timeStrToTimestamp(t: []const u8) !u32 {
    if (t.len != time_format.len) return Error.InvalidGpxTime;
    const year = try parseUint(u16, t[0..4], 10);
    if (year < 1970) return Error.InvalidGpxTime;
    const month = try parseUint(u4, t[5..7], 10);
    if (month < 1 or month > 12) return Error.InvalidGpxTime;
    const day = try parseUint(u5, t[8..10], 10);
    const hour = try parseUint(u6, t[11..13], 10);
    const minute = try parseUint(u6, t[14..16], 10);
    const second = try parseUint(u6, t[17..19], 10);

    var timestamp: u32 = 0;
    for (1970..year) |y| {
        timestamp += @as(u32, epoch.getDaysInYear(@intCast(y))) * seconds_in_day;
    }
    var day_index = daysToMonth[month - 1];
    if (month > 2 and isLeap(year)) day_index += 1;
    day_index += day - 1;

    timestamp += @as(u32, day_index) * seconds_in_day;

    const seconds: u17 = @as(u17, hour) * 3600 + @as(u17, minute) * 60 + second;
    return timestamp + seconds;
}

test timeStrToTimestamp {
    try testing.expect(try timeStrToTimestamp("2005-11-15T22:42:05Z") == 1132094525);
    try testing.expect(try timeStrToTimestamp("1995-02-19T21:05:00Z") == 793227900);
}
