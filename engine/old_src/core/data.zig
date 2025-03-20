pub const Bike = struct {
    id: u16,
    name: []const u8,
};

pub const Pursuit = struct {
    id: u32,
    name: []const u8,
    description: []const u8,
    kind: Kind,

    pub const Kind = enum {
        cycling,
        running,
        walking,
        hiking,
    };
};
