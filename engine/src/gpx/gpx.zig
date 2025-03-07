const std = @import("std");
const mem = std.mem;
const assert = std.debug.assert;
const testing = std.testing;
const fmt = std.fmt;

const indexOf = mem.indexOfPosLinear;

pub const Error = error{InvalidGpx};

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
        ele: f16,
        time: u32,

        pub const tagname = "trkpt";
    };
};

pub fn parse(a: mem.Allocator, gpx: []const u8) !Gpx {
    var result = Gpx.init(a);
    errdefer result.deinit();

    result.name = tagContent(gpx, "name") orelse return Error.InvalidGpx;
    result.type = tagContent(gpx, "type") orelse return Error.InvalidGpx;

    var pos: usize = 0;
    while (true) {
        const idx, const trkpt = tagAndIndex(gpx[pos..], Gpx.Trkpt.tagname) orelse
            return result;
        assert(trkpt.len >= 2 * Gpx.Trkpt.tagname.len + "<></>".len);
        const lat = attr(trkpt, "lat") orelse return Error.InvalidGpx;
        const lon = attr(trkpt, "lon") orelse return Error.InvalidGpx;
        const ele = tagContent(trkpt, "ele") orelse return Error.InvalidGpx;
        const time = tagContent(trkpt, "time") orelse return Error.InvalidGpx;

        try result.track.append(.{
            .lat = fmt.parseFloat(f64, lat) catch return Error.InvalidGpx,
            .lon = fmt.parseFloat(f64, lon) catch return Error.InvalidGpx,
            .ele = fmt.parseFloat(f16, ele) catch return Error.InvalidGpx,
            .time = @intCast(time.len), // FIXME
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
}

pub fn tagAndIndex(
    gpx: []const u8,
    comptime tag_name: []const u8,
) ?struct { usize, []const u8 } {
    const from = indexOf(u8, gpx, 0, "<" ++ tag_name) orelse
        return null;
    const closing_tag = "</" ++ tag_name ++ ">";
    const to = indexOf(u8, gpx, from + 1, closing_tag) orelse
        return null;
    return .{ from, gpx[from .. to + closing_tag.len] };
}

pub fn tag(gpx: []const u8, comptime tag_name: []const u8) ?[]const u8 {
    _, const tag_str = tagAndIndex(gpx, tag_name) orelse return null;
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

    const ele = tag(gpx, "ele");
    const time = tag(gpx, "time");
    const foo = tag(gpx, "foo");

    try testing.expect(mem.eql(u8, ele.?, "<ele>126.0</ele>"));
    try testing.expect(mem.eql(u8, time.?, "<time>2022-01-07T09:19:57Z</time>"));
    try testing.expect(mem.eql(u8, foo.?, "<foo attr1=\"val\">hello</foo>"));
    try testing.expect(tagContent("missingtag", gpx) == null);
}

pub fn tagContent(gpx: []const u8, comptime tag_name: []const u8) ?[]const u8 {
    const from = indexOf(u8, gpx, 0, "<" ++ tag_name) orelse return null;
    const content_idx = (indexOf(u8, gpx, from, ">") orelse return null) + 1;
    const closing_tag = "</" ++ tag_name ++ ">";
    const to = indexOf(u8, gpx, from + 1, closing_tag) orelse return null;
    return gpx[content_idx..to];
}

test tagContent {
    const gpx =
        \\<trkpt lat="48.9667130" lon="32.2284080">
        \\<ele>126.0</ele>
        \\<time>2022-01-07T09:19:57Z</time>
        \\</trkpt>
    ;

    const ele = tagContent(gpx, "ele");
    const time = tagContent(gpx, "time");

    try testing.expect(mem.eql(u8, ele.?, "126.0"));
    try testing.expect(mem.eql(u8, time.?, "2022-01-07T09:19:57Z"));
    try testing.expect(tagContent("missingtag", gpx) == null);
}

pub fn attr(gpx: []const u8, attr_name: []const u8) ?[]const u8 {
    var from = indexOf(u8, gpx, 0, attr_name) orelse return null;
    from += attr_name.len + "=\"".len;
    const to = indexOf(u8, gpx, from + 1, "\"") orelse return null;
    return gpx[from..to];
}

test attr {
    const gpx = "<trkpt lat=\"48.9667130\" lon=\"32.2284080\" foo=\"bar\">";

    const lon = attr(gpx, "lon");
    const lat = attr(gpx, "lat");
    const foo = attr(gpx, "foo");

    try testing.expect(mem.eql(u8, lat.?, "48.9667130"));
    try testing.expect(mem.eql(u8, lon.?, "32.2284080"));
    try testing.expect(mem.eql(u8, foo.?, "bar"));
    try testing.expect(attr("missing", gpx) == null);
}
