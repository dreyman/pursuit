const std = @import("std");
const t = std.testing;
const profile = @import("profile.zig");

const fit = @import("fit_protocol.zig");

test "just checking" {
    // const global_id = 0;
    // const f: FileIdMessage = .{
    //     .file_type = 0,
    //     .manufacturer = 1,
    //     .product = 2,
    //     .serial_number = 3,
    //     .time_created = 4,
    //     .number = 5,
    //     .create = inc,
    // };
    const data: fit.Message.Data = .{
        .arch = .little,
        .global_id = 20,
        .fields = &.{},
    };
    // const generated_func = genericCreateFunc(&record_fields, GRecord);
    // const rand_int = std.crypto.random.int(data);
    const res = createRecord(data) orelse unreachable;

    try t.expect(res.timestamp == 0);
    // try t.expect(res.file_type == 1);
    // try t.expect(res.manufacturer == 2);
    // try t.expect(res.product == 3);
    // try t.expect(res.serial_number == 4);
    // try t.expect(res.time_created == 5);
    // try t.expect(res.number == 6);
}

// global_id => MessageType => MessageType.create(bytes)

// pub fn MessageFromGlobalId(id: u16) type {
//     return switch (id) {
//         0 => GenericMessageType(&file_id_fields),
//         else => unreachable,
//     };
// }

pub const Record = GenericMessageType(&record_fields);
pub const createRecord = genericCreateFunc(&record_fields, Record);
pub const record_fields = [_]profile.Field{
    .{ .name = "timestamp", .type = u32, .id = 253 },
    .{ .name = "lat", .type = ?i32, .id = 0 },
    .{ .name = "lon", .type = ?i32, .id = 1 },
    .{ .name = "altitude", .type = ?u16, .id = 2, .scale = 5, .offset = 500 },
    .{ .name = "distance", .type = ?u32, .id = 5, .scale = 100 },
    .{ .name = "speed", .type = ?u16, .id = 6, .scale = 1000 },
    .{ .name = "grade", .type = ?u16, .id = 9, .scale = 100 },
    .{ .name = "temperature", .type = ?i8, .id = 13 },
};

pub const FileIdMessage = GenericMessageType(&file_id_fields);
pub const createFileId = genericCreateFunc(&file_id_fields, FileIdMessage);
pub const file_id_fields = [_]profile.Field{
    .{ .name = "file_type", .type = u8, .id = 0 },
    .{ .name = "manufacturer", .type = u16, .id = 1 },
    .{ .name = "product", .type = u16, .id = 2 },
    .{ .name = "serial_number", .type = u32, .id = 3 },
    .{ .name = "time_created", .type = u32, .id = 4 },
    .{ .name = "number", .type = u16, .id = 5 },
    // .{ .name = "product_name", .type = , .id =  },
};

pub fn genericCreateFunc(
    comptime fields: []const profile.Field,
    comptime MT: type,
) *const fn (fit.Message.Data) ?MT {
    const decodeFunc = struct {
        fn decode(message: fit.Message.Data) ?MT {
            var res: MT = undefined;
            inline for (fields) |field| {
                const type_info = @typeInfo(field.type);
                const field_type = switch (type_info) {
                    .optional => |opt| opt.child,
                    .int, .float => field.type,
                    else => @compileError("Unsupported field type"),
                };
                const val = message.decodeValue(field.id, field_type);
                if (val != null) {
                    @field(res, field.name) = val.?;
                } // fixme is else needed here?
            }
            return res;
        }
    }.decode;
    return decodeFunc;
}

pub fn GenericMessageType(comptime fields: []const profile.Field) type {
    var struct_fields = [_]std.builtin.Type.StructField{undefined} ** fields.len;
    inline for (fields, 0..) |field, idx| {
        struct_fields[idx] = .{
            .name = field.name,
            .type = field.type,
            .default_value_ptr = null,
            .is_comptime = false,
            .alignment = 0,
        };
    }
    return @Type(.{ .@"struct" = .{
        .layout = .auto,
        .fields = &struct_fields,
        .decls = &.{},
        .is_tuple = false,
    } });
}
