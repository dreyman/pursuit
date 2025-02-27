const std = @import("std");
const mem = std.mem;

// pub fn Point(comptime unit: CoordUnit) type {
//     return switch (unit) {
//         .semicircles => struct {
//             lat: i32,
//             lon: i32,
//             coordUnit: unit,
//         },
//         .degrees, .radians => struct {
//             lat: f32,
//             lon: f32,
//             coordUnit: unit,
//         },
//     };
// }

pub const Point = struct {
    lat: f32,
    lon: f32,
};

pub const Route = struct {
    points: []Point,
    timestamps: []u32,
    allocator: mem.Allocator,

    pub fn init(alloc: mem.Allocator, size: usize) !Route {
        // r.allocator = alloc;
        // r.points = try r.allocator.alloc(Point, size);
        // r.timestamps = try r.allocator.alloc(u32, size);
        return .{
            .allocator = alloc,
            .points = try alloc.alloc(Point, size),
            .timestamps = try alloc.alloc(u32, size),
        };
    }

    pub fn deinit(r: *Route) void {
        r.allocator.free(r.points);
        r.allocator.free(r.timestamps);
    }
};

// pub fn Point(unit: CoordUnit) type {
//     return struct {
//         lat: f32,
//         lon: f32,
//         unit: unit,
//     };
// }

// pub fn Route(unit: CoordUnit) type {
//     return struct {
//         points: []Point(unit),
//         timestamps: []u32,
//         allocator: mem.allocator,

//         pub fn init(r: *Route, alloc: mem.Allocator, size: usize) !void {
//             r.allocator = alloc;
//             r.points = try r.allocator.alloc(Point(unit), size);
//             r.timestamps = try r.allocator.alloc(u32, size);
//         }

//         pub fn deinit(r: *Route) void {
//             r.allocator.free(r.points);
//             r.allocator.free(r.timestamps);
//         }

//         pub fn convertTo(route: *Route, unit: CoordUnit) void {}
//     };
// }

// pub const Point = struct {
//     lat: f32,
//     lon: f32,
// };

// pub const Route = struct {
//     points: []Point,
//     timestamps: []u32,
// };

pub const CoordUnit = enum {
    semicircles,
    degrees,
    radians,
};
