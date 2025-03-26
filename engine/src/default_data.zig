const data = @import("data.zig");
const Pursuit = data.Pursuit;

pub const Medium = struct {
    pub const Kind = enum {
        bike,
        shoes,
    };

    pub const defaults = [_]Default{
        .{
            .id = 100,
            .kind = .bike,
            .name = "unknown bike",
        },
        .{
            .id = 99,
            .kind = .shoes,
            .name = "unknown shoes",
        },
    };
    pub const default_name = "unknown";

    pub const Default = struct {
        id: data.Medium.ID,
        kind: Kind,
        name: []const u8,
    };

    pub fn default(kind: Kind) Default {
        return switch (kind) {
            .bike => defaults[0],
            .shoes => defaults[1],
        };
    }

    pub fn defaultForPursuitKind(kind: Pursuit.Kind) ?Default {
        return switch (kind) {
            .cycling => default(.bike),
            .walking, .running, .hiking => default(.shoes),
            .unknown => null,
        };
    }

    pub fn mediumKindFromPursuitKind(kind: Pursuit.Kind) ?Kind {
        return switch (kind) {
            .cycling => .bike,
            .walking, .running, .hiking => .shoes,
            .unknown => null,
        };
    }
};
