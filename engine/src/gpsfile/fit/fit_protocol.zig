// https://developer.garmin.com/fit/protocol/

const std = @import("std");
const t = std.testing;
const assert = std.debug.assert;

pub const header_len_min = 12;
pub const header_len_max = 14;
pub const header_endianess = std.builtin.Endian.little;
pub const field_definition_bytes_len = 3;
pub const timestamp_offset: u32 = 631065600;

pub const Fit = struct {
    bytes: []const u8,
    header: Header,
    messages: std.ArrayList(Message.Data),
    alloc: std.mem.Allocator,

    pub fn deinit(self: *Fit) void {
        for (self.messages.items) |mesg| {
            self.alloc.free(mesg.fields);
        }
        self.messages.deinit();
        self.alloc.free(self.bytes);
    }
};

pub const Header = struct {
    bytes: []const u8,

    pub fn size(header: *const Header) u8 {
        return header.bytes[0];
    }

    pub fn protocolVersion(header: *const Header) u8 {
        return header.bytes[1];
    }

    pub fn profileVersion(header: *const Header) u16 {
        return std.mem.readVarInt(u16, header.bytes[2..4], header_endianess);
    }

    pub fn dataSize(header: *const Header) u32 {
        return std.mem.readVarInt(u32, header.bytes[4..8], header_endianess);
    }
};

pub const Message = struct {
    pub const Type = enum { definition, data };

    pub const Header = struct {
        byte: u8,

        pub const Type = enum { normal, compressed_timestamp };

        pub fn headerType(header: Message.Header) Message.Header.Type {
            return if ((header.byte & 0b10000000) == 0) .normal else .compressed_timestamp;
        }

        pub fn messageType(header: Message.Header) Message.Type {
            return switch (header.headerType()) {
                .normal => if ((header.byte >> 6) & 1 == 1) .definition else .data,
                .compressed_timestamp => .data,
            };
        }

        pub fn containsDevData(header: Message.Header) bool {
            return switch (header.headerType()) {
                .normal => @as(u1, @intCast((header.byte >> 5) & 1)) == 1,
                .compressed_timestamp => false,
            };
        }

        pub fn localId(header: Message.Header) u4 {
            return switch (header.headerType()) {
                .normal => @intCast(header.byte & 0b1111),
                .compressed_timestamp => @intCast((header.byte >> 5) & 0b011),
            };
        }

        pub fn timeOffset(header: Message.Header) u5 {
            return @intCast((header.byte >> 3) & 0b00011111);
        }
    };

    pub const Definition = struct {
        fields: []Message.Definition.Field,
        dev_fields: []Message.Definition.Field,
        // TODO mb get rid of `arch` field, just reverse byte array if arch == little
        arch: std.builtin.Endian,
        global_id: u16,
        local_id: u4,

        pub const Field = struct {
            id: u8,
            size: u8,
            base_type: u8,
        };
    };

    pub const Data = struct {
        arch: std.builtin.Endian,
        global_id: u16,
        fields: []const Field,

        pub const Field = struct {
            id: u8,
            base_type: u8,
            val: []const u8,
        };

        pub fn getFieldValueById(message: *const Message.Data, id: u8) ?[]const u8 {
            for (message.fields) |field| {
                if (field.id == id) return field.val;
            }
            return null;
        }

        pub fn decodeValue(
            message: *const Message.Data,
            id: u8,
            comptime T: type,
        ) ?T {
            const val = message.getFieldValueById(id) orelse return null;
            // fixme this won't work with non-int types
            return std.mem.readVarInt(T, val, message.arch);
        }
    };
};
