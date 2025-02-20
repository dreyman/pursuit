const std = @import("std");
const fieldInfo = std.meta.fieldInfo;
const fit_protocol = @import("fit_protocol.zig");
const Fit = fit_protocol.Fit;
const FitData = fit_protocol.FitData;

pub const Error = error{ Invalid, UnknownFieldId };

pub const message_file_id = 0;
pub const message_device_settings = 2;
pub const message_record = 20;
pub const message_event = 21;
pub const message_session = 18;
pub const message_activity = 34;

pub const message_file_id_type_activity = 4;

pub const MessageId = enum(u8) {
    file_id = 0,
    device_settings = 2,
    record = 20,
    event = 21,
    session = 18,
    activity = 34,
};

pub const FileId = struct {
    type: u8,
    manufacturer: u16,
    product: u16,
    serial_number: u32,
    time_created: u32,
    number: u16,
    product_name: ?i16 = null,

    pub fn create(message: FitData.Message) !FileId {
        return .{
            .type = message.decodeValue(0, fieldInfo(FileId, .type).type) orelse return Error.Invalid,
            .manufacturer = message.decodeValue(1, fieldInfo(FileId, .manufacturer).type) orelse return Error.Invalid,
            .product = message.decodeValue(2, fieldInfo(FileId, .product).type) orelse return Error.Invalid,
            .serial_number = message.decodeValue(3, fieldInfo(FileId, .serial_number).type) orelse return Error.Invalid,
            .time_created = message.decodeValue(4, fieldInfo(FileId, .time_created).type) orelse return Error.Invalid,
            .number = message.decodeValue(5, fieldInfo(FileId, .number).type) orelse return Error.Invalid,
            // fixme add product name field (id = 8)
        };
    }
};

pub const Record = struct {
    timestamp: u32,
    lat: ?f32 = null,
    lon: ?f32 = null,
    altitude: ?u16 = null, // scale=5 offset=500
    distance: ?u32 = null, // scale=100 offset=0
    speed: ?u16 = null, // scale=1000 offset=0
    grade: ?u16 = null, // scale=100 offset=0
    temperature: ?i8 = null,

    pub fn create(message: FitData.Message) !Record {
        return .{
            .timestamp = fit_protocol.timestamp_offset + (message.decodeValue(253, fieldInfo(Record, .timestamp).type) orelse return Error.Invalid),
            .lat = semicirclesToDegrees(message.decodeValue(0, i32) orelse null),
            .lon = semicirclesToDegrees(message.decodeValue(1, i32) orelse null),
            .altitude = message.decodeValue(2, u16) orelse null,
            .distance = message.decodeValue(5, u32) orelse null,
            .speed = message.decodeValue(6, u16) orelse null,
            .grade = message.decodeValue(9, u16) orelse null,
            .temperature = message.decodeValue(13, i8) orelse null,
        };
    }
};

// pub const Event = struct {
//     timestamp: u32,
//     event: u8,
//     event_type: u8,
// };

pub const Session = struct {
    message_index: u16, // 254
    timestamp: u32, // 253
    event: u8, // 0
    event_type: u8, // 1
    start_time: u32, // 2
    start_position_lat: i32, // 3
    start_position_lon: i32, // 4
    sport: u8, // 5
    sub_sport: u8, // 6
    total_elapsed_time: u32, // 7 scale=1000
    total_timer_time: u32, // 8 scale=1000
    total_distance: u32, // 9 scale=100
    total_cycles: u32, // 10
    avg_speed: u16, // 14 scale=1000
    max_speed: u16, // 15 scale=1000
    total_ascent: u16, // 22
    total_descent: u16, // 23
    end_position_lat: i32, // 38
    end_position_lon: i32, // 39
    avg_temperature: i8, // 57
    max_temperature: i8, // 58
    total_moving_time: u32, // 59 scale=1000
};

pub const Activity = struct {
    timestamp: u32, // 253
    total_timer_time: u32, // 0 scale=1000
    num_sessions: u16, // 1
    type: u8, // 2
    event: u8, // 3
    event_type: u8, // 4
    local_timestamp: u32, // 5
    event_group: u8, // 6
};

pub const DeviceSettings = struct {};

fn semicirclesToDegrees(semicircles: ?i32) ?f32 {
    if (semicircles == null) return null;
    const radians = (@as(f32, @floatFromInt(semicircles.?)) * std.math.pi) / 0x80000000;
    return std.math.radiansToDegrees(radians);
}

pub fn getMessageName(mesg_num: u16) []const u8 {
    const mesg_type = std.meta.intToEnum(MessageId, mesg_num) catch null;
    return if (mesg_type != null) @tagName(mesg_type.?) else "unknown";
}
