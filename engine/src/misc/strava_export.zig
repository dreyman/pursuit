const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const fs = std.fs;

const csv = @import("csv.zig");

pub const Error = error{InvalidActivityFieldValue};

const id_idx = 0;
const name_idx = 2;
const type_idx = 3;
const description_idx = 4;
const gear_idx = 11;
const filename_idx = 12;

pub const ID = u64;
pub const Activity = struct {
    alloc: Allocator,
    id: ID,
    name: []u8,
    kind: []u8,
    description: []u8,
    gear: []u8,
    file: []u8,

    pub fn createFromCsvRecord(
        alloc: Allocator,
        rec: [][]const u8,
    ) !*Activity {
        const a = try alloc.create(Activity);
        errdefer alloc.destroy(a);
        const id = try std.fmt.parseInt(ID, rec[id_idx], 10);

        const name = try copyValue(alloc, rec[name_idx]);
        errdefer alloc.free(name);
        const kind = try copyValue(alloc, rec[type_idx]);
        errdefer alloc.free(kind);
        const descr = try copyValue(alloc, rec[description_idx]);
        errdefer alloc.free(descr);
        const gear = try copyValue(alloc, rec[gear_idx]);
        errdefer alloc.free(gear);
        const filename = try copyValue(alloc, rec[filename_idx]);
        errdefer alloc.free(filename);

        a.* = .{
            .alloc = alloc,
            .id = id,
            .name = name,
            .kind = kind,
            .description = descr,
            .gear = gear,
            .file = filename,
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

    fn copyValue(alloc: Allocator, val: []const u8) ![]u8 {
        const res = try alloc.alloc(u8, val.len);
        @memcpy(res, val);
        return res;
    }
};

pub fn processStravaExport(alloc: Allocator, export_dir: []const u8) !ArrayList(*Activity) {
    var dir = try fs.cwd().openDir(export_dir, .{});
    defer dir.close();

    const csv_content = try dir.readFileAlloc(
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
        // if (i > 3) break;
        try acs.append(try Activity.createFromCsvRecord(alloc, rec.items));
    }
    return acs;
}

const SimpleAc = struct {
    id: ID,
    name: []u8,
    kind: []u8,
    description: []u8,
    gear: []u8,
    file: []u8,
};

test processStravaExport {
    const t = std.testing;
    const export_dir_path = "/home/ihor/stuff/export_53360041";
    var acs = try processStravaExport(t.allocator, export_dir_path);
    defer {
        for (acs.items) |ac| ac.destroy();
        acs.deinit();
    }
    std.debug.print("N of Activities: {d}\n", .{acs.items.len});
    // for (acs.items, 0..) |ac, i| {
    //     if (i % 30 == 0)
    //         std.debug.print("{s}: {s} {s} ({d})\n", .{ ac.name, ac.kind, ac.gear, ac.id });
    // }
    var home = try fs.cwd().openDir("/home/ihor", .{});
    defer home.close();
    const jsonfile = try home.createFile("MY_ACTIVITIES.json", .{});
    defer jsonfile.close();
    // var list = try ArrayList(*SimpleAc).initCapacity(t.allocator, acs.items.len);
    // defer {
    //     for (list.items) |sa| t.allocator.destroy(sa);
    //     list.deinit();
    // }
    const w = jsonfile.writer();
    _ = try w.write("[\n");
    for (acs.items, 0..) |ac, i| {
        // if (i > 30) break;
        const sa = try t.allocator.create(SimpleAc);
        defer t.allocator.destroy(sa);
        sa.* = .{
            .id = ac.id,
            .name = ac.name,
            .kind = ac.kind,
            .description = ac.description,
            .gear = ac.gear,
            .file = ac.file,
        };
        try std.json.stringify(
            sa,
            .{ .whitespace = .indent_4 },
            jsonfile.writer(),
        );
        if (i < acs.items.len - 1) _ = try w.write(",\n");
        // try list.append(sa);
    }
    _ = try w.write("\n]");
    // for (list.items) |item| {
    //     try std.json.stringify(
    //         item,
    //         .{ .whitespace = .indent_4 },
    //         jsonfile.writer(),
    //     );
    // }
    // try std.json.stringify(
    //     list,
    //     .{ .whitespace = .indent_4 },
    //     jsonfile.writer(),
    // );
    std.debug.print("DONE\n", .{});

    try t.expect(4 == 4);
}
