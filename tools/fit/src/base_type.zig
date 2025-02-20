pub const BaseType = struct {
    size: u4,
    name: []const u8,
    id: u8,
};

pub const base_types = [_]BaseType{
    .{ .size = 1, .name = "enum", .id = 0 },
    .{ .size = 1, .name = "sint8", .id = 1 },
    .{ .size = 1, .name = "uint8", .id = 2 },
    .{ .size = 2, .name = "sint16", .id = 131 },
    .{ .size = 2, .name = "uint16", .id = 132 },
    .{ .size = 4, .name = "sint32", .id = 133 },
    .{ .size = 4, .name = "uint32", .id = 134 },
    // Null terminated string encoded in UTF-8 format
    .{ .size = 1, .name = "sint16", .id = 7 },
    .{ .size = 4, .name = "float32", .id = 136 },
    .{ .size = 8, .name = "float64", .id = 137 },
    .{ .size = 1, .name = "uint8z", .id = 10 },
    .{ .size = 2, .name = "uint16z", .id = 139 },
    .{ .size = 4, .name = "uint32z", .id = 140 },
    // Array of bytes. Field is invalid if all bytes are invalid.
    .{ .size = 1, .name = "byte", .id = 13 },
    .{ .size = 8, .name = "sint64", .id = 142 },
    .{ .size = 8, .name = "uint64", .id = 143 },
    .{ .size = 8, .name = "uint64z", .id = 144 },
};

// pub fn BaseTypeType(bt: BaseType) type {
//     switch (bt.id) {
//         0 => u8,
//         1 => i8,
//         2 => u8,
//         131 => i16,
//         132 => u16,
//         133 => i32,
//         134 => u32,
//         7 => unreachable,
//         136 => f32,
//         137 => f64,
//         10 => u8,
//         139 => u32,
//         140 => u32,
//         13 => unreachable,
//         142 => u64,
//         143 => u64,
//         144 => u64,
//     }
// }
