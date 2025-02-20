// https://developer.garmin.com/fit/protocol/

const std = @import("std");
const t = std.testing;
const assert = std.debug.assert;

pub const fit_header_len_min = 12;
pub const fit_header_len_max = 14;
pub const fit_header_endianess = std.builtin.Endian.little;
pub const field_definition_bytes_len = 3;
pub const timestamp_offset: u32 = 631065600;

pub const FitData = struct {
    header: RawFit.Header,
    messages: std.ArrayList(Message),
    alloc: std.mem.Allocator,

    pub fn deinit(self: *FitData) void {
        for (self.messages.items) |mesg| {
            self.alloc.free(mesg.fields);
        }
        self.messages.deinit();
    }

    pub const Message = struct {
        arch: std.builtin.Endian,
        global_id: u16,
        fields: []const Field,

        pub const Field = struct {
            id: u8,
            base_type: u8,
            val: []const u8,
        };

        pub fn getFieldValueById(message: *const Message, id: u8) ?[]const u8 {
            for (message.fields) |field| {
                if (field.id == id) return field.val;
            }
            return null;
        }

        pub fn decodeValue(
            message: *const Message,
            id: u8,
            comptime T: type,
        ) ?T {
            const val = message.getFieldValueById(id) orelse return null;
            return std.mem.readVarInt(T, val, message.arch);
        }
    };
};

pub const RawFit = struct {
    alloc: std.mem.Allocator,
    protocol_version: u8,
    profile_version: u16,
    data_size: u32,
    messages: std.ArrayList(RawFit.Message.Data),
    definitions: std.ArrayList(RawFit.Message.Definition),

    pub fn deinit(fit: *const RawFit) void {
        for (fit.messages.items) |mesg| {
            fit.alloc.free(mesg.fields);
        }
        for (fit.definitions.items) |def| {
            fit.alloc.free(def.fields);
            fit.alloc.free(def.dev_fields);
        }
        fit.messages.deinit();
        fit.definitions.deinit();
    }

    pub const Header = struct {
        bytes: []const u8,

        pub fn size(header: *const RawFit.Header) u8 {
            return header.bytes[0];
        }

        pub fn protocolVersion(header: *const RawFit.Header) u8 {
            return header.bytes[1];
        }

        pub fn profileVersion(header: *const RawFit.Header) u16 {
            return std.mem.readVarInt(u16, header.bytes[2..4], fit_header_endianess);
        }

        pub fn dataSize(header: *const RawFit.Header) u32 {
            return std.mem.readVarInt(u32, header.bytes[4..8], fit_header_endianess);
        }
    };

    pub const Message = union(RawFit.Message.Type) {
        definition: Definition,
        data: Data,

        pub const Type = enum { definition, data };
        pub const Header = struct {
            byte: u8,

            pub const Type = enum { normal, compressed_timestamp };

            pub fn headerType(header: RawFit.Message.Header) RawFit.Message.Header.Type {
                return if (((header.byte >> 7) & 1) == 0) .normal else .compressed_timestamp;
            }

            pub fn messageType(header: RawFit.Message.Header) RawFit.Message.Type {
                return switch (header.headerType()) {
                    .normal => if ((header.byte >> 6) & 1 == 1) .definition else .data,
                    .compressed_timestamp => .data,
                };
            }

            pub fn containsDevData(header: RawFit.Message.Header) bool {
                return switch (header.headerType()) {
                    .normal => @as(u1, @intCast((header.byte >> 5) & 1)) == 1,
                    .compressed_timestamp => false,
                };
            }

            pub fn localId(header: RawFit.Message.Header) u4 {
                return switch (header.headerType()) {
                    .normal => @intCast(header.byte & 0b1111),
                    .compressed_timestamp => @intCast((header.byte >> 5) & 0b011),
                };
            }

            pub fn timeOffset(header: RawFit.Message.Header) u5 {
                return @intCast((header.byte >> 3) & 0b00011111);
            }
        };

        pub const Definition = struct {
            fields: []RawFit.Message.Definition.Field,
            dev_fields: []RawFit.Message.Definition.Field,
            // fields: std.ArrayList(RawFit.Message.Definition.Field),
            // dev_fields: std.ArrayList(RawFit.Message.Definition.Field),
            arch: std.builtin.Endian,
            global_id: u16,
            local_id: u4,

            pub const Field = struct {
                // The Field Definition Number uniquely identifies a specific FIT field of the given FIT message.
                // The field definition numbers for each global FIT message are provided in the SDK.
                // 255 represents an invalid field number.
                id: u8,
                // The Size indicates the size of the defined field in bytes.
                // The size may be a multiple of the underlying FIT Base Type size indicating the field
                // contains multiple elements represented as an array.
                size: u8,
                // Base Type describes the FIT field as a specific type of FIT variable (unsigned char, signed short, etc).
                // This allows the FIT decoder to appropriately handle invalid or unknown data of this type.
                // The format of the base type bit field is shown below in Table 6.
                // All available Base Types are fully defined in the fit.h file included in the SDK.
                base_type: u8,
            };
        };
        pub const Data = struct {
            header: RawFit.Message.Header,
            definition: *const RawFit.Message.Definition,
            fields: []const RawFit.Message.Data.Field,

            pub const Field = struct {
                data: []const u8,
                // definition: *const RawFit.Message.Definition.Field,
            };
        };
    };
};

pub const Fit = struct {
    header: Fit.Header,
    records: std.ArrayList(Fit.Record),
    // records
    // crc?

    pub fn deinit(fit: *const Fit) void {
        for (fit.records.items) |record| {
            switch (record.content) {
                .definition => |def| def.field_definitions.deinit(),
                .data => |data| data.fields.deinit(),
            }
        }
        fit.records.deinit();
        // switch (fit.record1.content) {
        //     .definition => |def| def.field_definitions.deinit(),
        //     .data => |data| data.fields.deinit(),
        // }
        // switch (fit.record2.content) {
        //     .definition => |def| def.field_definitions.deinit(),
        //     .data => |data| data.fields.deinit(),
        // }
        // switch (fit.record3.content) {
        //     .definition => |def| def.field_definitions.deinit(),
        //     .data => |data| data.fields.deinit(),
        // }
        // switch (fit.record4.content) {
        //     .definition => |def| def.field_definitions.deinit(),
        //     .data => |data| data.fields.deinit(),
        // }
    }

    pub const Header = struct {
        // Indicates the length of this file header including header size.
        // Minimum size is 12. This may be increased in future to add additional optional information
        size: u8,
        // Protocol version number as provided in SDK
        protocol_version: u8,
        // Profile version number as provided in SDK
        profile_version: u16,
        //  Length of the Data Records section in bytes. Does not include Header or CRC
        data_size: u32,
        // ASCII values for “.FIT”. A FIT binary file opened with a text editor
        // will contain a readable “.FIT” in the first line.
        data_type: [4]u8,
        // Contains the value of the CRC (see CRC) of Bytes 0 through 11,
        // or may be set to 0x0000. This field is optional.
        crc: u16,
    };

    pub const Record = struct {
        header: Record.Header,
        content: Record.Content,

        pub const Type = enum {
            // In a definition message, the local message type is assigned to a Global FIT Message Number (mesg_num)
            // relating the local messages to their respective FIT messages
            definition,
            // The local message type associates a data message to its respective definition message,
            // and hence, its' global FIT message. A data message will follow the format as specified
            // in its definition message of matching local message type.
            data,
        };

        pub const Header = struct {
            data: u8,
            type: Record.Header.Type,
            record_type: Fit.Record.Type,
            local_message_type: u4,
            contains_dev_data: bool,

            pub const Type = enum {
                normal,
                compressed_timestamp,
            };
        };

        pub const Content = union(Record.Type) {
            definition: Record.Definition,
            data: Record.Data,
        };

        pub const Definition = struct {
            arch: std.builtin.Endian,
            global_message_number: u16,
            fields_count: u8,
            field_definitions: std.ArrayList(Field),
            dev_field_definitions: ?std.ArrayList(Field) = null,

            pub const Field = struct {
                // The Field Definition Number uniquely identifies a specific FIT field of the given FIT message.
                // The field definition numbers for each global FIT message are provided in the SDK.
                // 255 represents an invalid field number.
                field_def_number: u8,
                // The Size indicates the size of the defined field in bytes.
                // The size may be a multiple of the underlying FIT Base Type size indicating the field
                // contains multiple elements represented as an array.
                size: u8,
                // Base Type describes the FIT field as a specific type of FIT variable (unsigned char, signed short, etc).
                // This allows the FIT decoder to appropriately handle invalid or unknown data of this type.
                // The format of the base type bit field is shown below in Table 6.
                // All available Base Types are fully defined in the fit.h file included in the SDK.
                base_type: u8,
                dev: bool = false,
            };
        };

        pub const Data = struct {
            fields: std.ArrayList(Field),

            pub const Field = struct {
                data: []u8,
                definition: Definition.Field,
            };
        };
    };
};

// pub fn getBaseType(base_type_id: u8) {
//     switch (base_type_id) {

//     }
// }

pub fn createFitHeader(bytes: []u8) struct { usize, Fit.Header } {
    assert(bytes.len >= fit_header_len_min);
    const header_size = bytes[0];
    const crc = if (header_size == fit_header_len_max and bytes.len == fit_header_len_max)
        std.mem.readVarInt(u16, bytes[12..14], .little)
    else
        0;
    return .{
        fit_header_len_max,
        .{
            .size = header_size,
            .protocol_version = bytes[1],
            .profile_version = std.mem.readVarInt(u16, bytes[2..4], .little),
            .data_size = std.mem.readVarInt(u32, bytes[4..8], .little),
            .data_type = [_]u8{
                bytes[8],
                bytes[9],
                bytes[10],
                bytes[11],
            },
            .crc = crc,
        },
    };
}

pub fn createRecordHeader(data: u8) Fit.Record.Header {
    const header_type_val = (data >> 7) & 1;
    const header_type: Fit.Record.Header.Type = if (header_type_val == 0) .normal else .compressed_timestamp;
    const dev_data: u1 = @intCast((data >> 5) & 1);
    return switch (header_type) {
        .normal => .{
            .data = data,
            .local_message_type = @intCast(data & 0b1111),
            .contains_dev_data = dev_data == 1,
            .record_type = if ((data >> 6) & 1 == 1) .definition else .data,
            .type = header_type,
        },
        .compressed_timestamp => .{
            .data = data,
            .local_message_type = @intCast((data >> 5) & 0b011),
            .contains_dev_data = false,
            .record_type = .data,
            .type = header_type,
        },
    };
}

pub fn createFieldDefinition(data: [3]u8) Fit.Record.Definition.Field {
    return .{
        .field_def_number = data[0],
        .size = data[1],
        .base_type = data[2],
        // .base_type = @intCast(data[2] >> 3),
        // .endian_ability = data[2] & 1 == 1,
    };
}

test "creates fit header from byte array" {
    var bytes = [fit_header_len_max]u8{
        14,
        16,
        242,
        3,
        205,
        31,
        1,
        0,
        46,
        70,
        73,
        84,
        241,
        165,
    };
    const size, const fit_header = createFitHeader(bytes[0..]);

    try t.expectEqual(14, size);
    try t.expectEqual(14, fit_header.size);
    try t.expectEqual(16, fit_header.protocol_version);
    try t.expectEqual(1010, fit_header.profile_version);
    try t.expectEqual(73_677, fit_header.data_size);
    try t.expect(std.mem.eql(u8, ".FIT", &fit_header.data_type));
    try t.expectEqual(42481, fit_header.crc);
}
