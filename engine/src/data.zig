const std = @import("std");
const mem = std.mem;
const math = std.math;
const Allocator = mem.Allocator;

pub const Pursuit = struct {
    id: ID,
    name: []const u8,
    description: []const u8,
    kind: Kind,
    medium_id: ?Medium.ID,

    pub const ID = u32;

    pub fn destroy(p: *Pursuit, alloc: Allocator) void {
        alloc.free(p.name);
        alloc.free(p.description);
        alloc.destroy(p);
    }

    pub const Kind = enum {
        cycling,
        running,
        walking,
        unknown,

        pub fn verb(kind: Kind) []const u8 {
            return switch (kind) {
                .unknown => "unknown activity",
                .cycling => "ride",
                .running => "run",
                .walking => "walk",
            };
        }
    };
};

pub const Medium = struct {
    id: ID,
    kind: []const u8,
    name: []const u8,
    created_at: u32,

    pub const ID = u32;
    pub const Kind = enum {
        bike,
        shoes,
    };

    pub fn createEmpty(
        alloc: Allocator,
        kind: []const u8,
        name: []const u8,
    ) !*Medium {
        const m = try alloc.create(Medium);
        m.* = .{
            .id = 0,
            .kind = kind,
            .name = name,
            .created_at = @intCast(std.time.timestamp()),
        };
        return m;
    }
};
