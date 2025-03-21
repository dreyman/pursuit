const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;

pub const Csv = struct {
    alloc: Allocator,
    content: []const u8,
    header: ArrayList(V),
    records: ArrayList(ArrayList(V)),

    pub const V = []const u8;

    pub fn create(alloc: Allocator, csv_content: []const u8) !*Csv {
        const csv = try alloc.create(Csv);
        csv.* = .{
            .alloc = alloc,
            .content = csv_content,
            .header = ArrayList(V).init(alloc),
            .records = ArrayList(ArrayList(V)).init(alloc),
        };
        return csv;
    }

    pub fn destroy(csv: *Csv) void {
        for (csv.records.items) |rec| rec.deinit();
        csv.records.deinit();
        csv.header.deinit();
        csv.alloc.free(csv.content);
        csv.alloc.destroy(csv);
    }

    pub fn record(csv: *Csv, idx: usize) ArrayList(V) {
        return csv.records.items[idx];
    }
};

pub const Error = error{InvalidCsv};
pub const ParseError = Allocator.Error || Error;

pub fn parse(alloc: Allocator, csv: []const u8) ParseError!*Csv {
    var result = try Csv.create(alloc, csv);
    errdefer result.destroy();
    var pos: usize = 0;
    while (true) {
        const idx = valueLen(csv[pos..]);
        try result.header.append(csv[pos .. pos + idx]);
        pos += idx + 1;
        if (pos < csv.len and csv[pos - 1] == '\n')
            break;
    }
    while (pos < csv.len) {
        var record = ArrayList(Csv.V).init(alloc);
        errdefer record.deinit();
        for (0..result.header.items.len) |_| {
            if (pos >= csv.len)
                return Error.InvalidCsv;
            const len = valueLen(csv[pos..]);
            // if (len == 0) {
            //     try record.append(null);
            // } else {
            const quotes = csv[pos] == '"' and csv[pos + len - 1] == '"';
            if (quotes) {
                // if (len == 2) {
                //     try record.append(null);
                // } else {
                try record.append(csv[pos + 1 .. pos + len - 1]);
                // }
            } else {
                try record.append(csv[pos .. pos + len]);
            }
            // }

            pos += len + 1;
        }
        try result.records.append(record);
    }
    return result;
}

fn valueLen(csv: []const u8) usize {
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

test parse {
    const t = std.testing;
    {
        const csv_test =
            \\First,Second,Third
            \\first,second,third
            \\"",,""text in quotes""
            \\"Dec 12, 2021","Multiline,
            \\value",some text
            \\,"",,
        ;
        const csv_content = try t.allocator.alloc(u8, csv_test.len);
        @memcpy(csv_content, csv_test);
        var csv = try parse(t.allocator, csv_content);
        defer csv.destroy();

        try t.expect(csv.header.items.len == 3);
        try t.expect(csv.records.items.len == 4);
        try t.expect(mem.eql(u8, csv.record(0).items[0], "first"));
        try t.expect(mem.eql(u8, csv.record(0).items[1], "second"));
        try t.expect(mem.eql(u8, csv.record(0).items[2], "third"));

        try t.expect(csv.record(1).items[0].len == 0);
        try t.expect(csv.record(1).items[1].len == 0);
        try t.expect(mem.eql(u8, csv.record(1).items[2], "\"text in quotes\""));

        try t.expect(mem.eql(u8, csv.record(2).items[0], "Dec 12, 2021"));
        try t.expect(mem.eql(u8, csv.record(2).items[1], "Multiline,\nvalue"));
        try t.expect(mem.eql(u8, csv.record(2).items[2], "some text"));

        try t.expect(csv.record(3).items[0].len == 0);
        try t.expect(csv.record(3).items[1].len == 0);
        try t.expect(csv.record(3).items[2].len == 0);
    }
    {
        const csv_test =
            \\First,Second,Third
            \\first,second,third
            \\no third,value
        ;
        const csv_content = try t.allocator.alloc(u8, csv_test.len);
        @memcpy(csv_content, csv_test);

        try t.expectError(Error.InvalidCsv, parse(t.allocator, csv_content));
    }
}
