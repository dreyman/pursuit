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
//
const distance_idx = 17;

pub const Activity = struct {
    alloc: Allocator,
    id: ID,
    name: []u8,
    kind: []u8,
    description: []u8,
    gear: []u8,
    file: []u8,
    //
    distance: f64,

    pub const ID = u64;

    pub fn createFromList(
        alloc: Allocator,
        rec: [][]const u8,
    ) !*Activity {
        const a = try alloc.create(Activity);
        errdefer alloc.destroy(a);

        const id = try std.fmt.parseInt(Activity.ID, rec[id_idx], 10);

        const name = try alloc.dupe(u8, rec[name_idx]);
        errdefer alloc.free(name);

        const kind = try alloc.dupe(u8, rec[type_idx]);
        errdefer alloc.free(kind);

        const descr = try alloc.dupe(u8, rec[description_idx]);
        errdefer alloc.free(descr);

        const gear = try alloc.dupe(u8, rec[gear_idx]);
        errdefer alloc.free(gear);

        const filename = try alloc.dupe(u8, rec[filename_idx]);
        errdefer alloc.free(filename);

        const distance = try std.fmt.parseFloat(f64, rec[distance_idx]);

        a.* = .{
            .alloc = alloc,
            .id = id,
            .name = name,
            .kind = kind,
            .description = descr,
            .gear = gear,
            .file = filename,
            //
            .distance = distance,
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

pub fn processStravaArchive(
    alloc: Allocator,
    archive_dir: []const u8,
) !ArrayList(*Activity) {
    var dir = try fs.cwd().openDir(archive_dir, .{});
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
        try acs.append(try Activity.createFromList(alloc, rec.items));
    }
    return acs;
}
