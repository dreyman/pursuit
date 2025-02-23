const std = @import("std");
const assert = std.debug.assert;

const fit = @import("fit_protocol.zig");

pub const file_id_type_activity = 4;

pub const CommonMessage = enum(u16) {
    file_id = 0,
    device_settings = 2,
    session = 18,
    record = 20,
    event = 21,
    activity = 34,
};

pub const Field = struct {
    name: [:0]const u8,
    type: type,
    id: u8,
    scale: u32 = 1,
    offset: i32 = 0,

    pub const timestamp = 253;
    pub const message_index = 254;
};

pub const Sport = enum(u8) {
    running = 1,
    cycling = 2,
    walking = 11,
    hiking = 17,
};

pub fn Message(comptime fields: []const Field) type {
    var struct_fields = [_]std.builtin.Type.StructField{undefined} ** fields.len;
    inline for (fields, 0..) |field, idx| {
        const ti = @typeInfo(field.type);
        assert(ti == .int or (ti == .optional and @typeInfo(ti.optional.child) == .int));
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

pub fn decodeFn(
    comptime fields: []const Field,
) *const fn (fit.Message.Data) ?Message(fields) {
    const decode = struct {
        fn decode(message: fit.Message.Data) ?Message(fields) {
            var res: Message(fields) = undefined;
            inline for (fields) |field| {
                const type_info = @typeInfo(field.type);
                const field_type = switch (type_info) {
                    .optional => |opt| opt.child,
                    .int => field.type,
                    else => @compileError("Unsupported field type"),
                };
                const val = message.decodeValue(field.id, field_type);
                if (val != null) {
                    @field(res, field.name) = val.?;
                } else if (type_info == .optional) {
                    @field(res, field.name) = null;
                }
            }
            return res;
        }
    }.decode;
    return decode;
}

pub const FileId = Message(&file_id_fields);
pub const decodeFileId = decodeFn(&file_id_fields);
pub const file_id_fields = [_]Field{
    .{ .name = "file_type", .type = u8, .id = 0 },
    .{ .name = "manufacturer", .type = u16, .id = 1 },
    .{ .name = "product", .type = u16, .id = 2 },
    .{ .name = "serial_number", .type = u32, .id = 3 },
    .{ .name = "time_created", .type = u32, .id = 4 },
    .{ .name = "number", .type = u16, .id = 5 },
};

pub const Record = Message(&record_fields);
pub const decodeRecord = decodeFn(&record_fields);
pub const record_fields = [_]Field{
    .{ .name = "timestamp", .type = u32, .id = Field.timestamp },
    .{ .name = "lat", .type = ?i32, .id = 0 },
    .{ .name = "lon", .type = ?i32, .id = 1 },
    .{ .name = "altitude", .type = ?u16, .id = 2, .scale = 5, .offset = 500 },
    .{ .name = "distance", .type = ?u32, .id = 5, .scale = 100 },
    .{ .name = "speed", .type = ?u16, .id = 6, .scale = 1000 },
    .{ .name = "grade", .type = ?u16, .id = 9, .scale = 100 },
    .{ .name = "temperature", .type = ?i8, .id = 13 },
};

pub const Session = Message(&session_fields);
pub const decodeSession = decodeFn(&session_fields);
pub const session_fields = [_]Field{
    .{ .name = "message_index", .type = ?u16, .id = Field.message_index },
    .{ .name = "timestamp", .type = ?u32, .id = Field.timestamp },
    .{ .name = "event", .type = ?u8, .id = 0 },
    .{ .name = "event_type", .type = ?u8, .id = 1 },
    .{ .name = "start_time", .type = ?u32, .id = 2 },
    .{ .name = "start_position_lat", .type = ?i32, .id = 3 },
    .{ .name = "start_position_lon", .type = ?i32, .id = 4 },
    .{ .name = "sport", .type = ?u8, .id = 5 }, // running = 1, cycling = 2
    .{ .name = "sub_sport", .type = ?u8, .id = 6 },
    .{ .name = "total_elapsed_time", .type = ?u32, .id = 7, .scale = 1000 },
    .{ .name = "total_timer_time", .type = ?u32, .id = 8, .scale = 1000 },
    .{ .name = "total_distance", .type = ?u32, .id = 9, .scale = 100 },
    .{ .name = "total_cycles", .type = ?u32, .id = 10 },
    .{ .name = "avg_speed", .type = ?u16, .id = 14, .scale = 1000 },
    .{ .name = "max_speed", .type = ?u16, .id = 15, .scale = 1000 },
    .{ .name = "total_ascent", .type = ?u16, .id = 22 },
    .{ .name = "total_descent", .type = ?u16, .id = 23 },
    .{ .name = "end_position_lat", .type = ?i32, .id = 38 },
    .{ .name = "end_position_lon", .type = ?i32, .id = 39 },
    .{ .name = "avg_temperature", .type = ?i8, .id = 57 },
    .{ .name = "max_temperature", .type = ?i8, .id = 58 },
    .{ .name = "min_temperature", .type = ?i8, .id = 150 },
    .{ .name = "total_moving_time", .type = ?u32, .id = 59, .scale = 1000 },
};

pub const Activity = Message(&activity_fields);
pub const decodeActivity = decodeFn(&activity_fields);
pub const activity_fields = [_]Field{
    .{ .name = "timestamp", .type = u32, .id = Field.timestamp },
    .{ .name = "total_timer_time", .type = u32, .id = 0, .scale = 1000 },
    .{ .name = "num_sessions", .type = u16, .id = 1 },
    .{ .name = "type", .type = u8, .id = 2 },
    .{ .name = "event", .type = u8, .id = 3 },
    .{ .name = "event_type", .type = u8, .id = 4 },
    .{ .name = "local_timestamp", .type = u32, .id = 5 },
    .{ .name = "event_group", .type = u8, .id = 6 },
};
