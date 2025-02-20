const fit_protocol = @import("fit_protocol.zig");
const FitData = fit_protocol.FitData;

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

    pub fn create(message: FitData.Message) !Session {
        return .{


            .timestamp = fit_protocol.timestamp_offset + (message.decodeValue(253, fieldInfo(Record, .timestamp).type),
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
