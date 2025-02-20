const std = @import("std");
const io = std.io;
const fs = std.fs;
const print = std.debug.print;
const testing = std.testing;
const assert = std.debug.assert;

const fit_file = "/home/ihor/code/zig-plgrnd/example.fit";
const MAX_HEADER_SIZE = 14;

const FitFileHeader = struct {
    // Indicates the length of this file header including header size.
    // Minimum size is 12. This may be increased in future to add additional optional information
    header_size: u8,
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

    pub fn createFromBytes(bytes: [MAX_HEADER_SIZE]u8) FitFileHeader {
        const header_size = bytes[0];
        // fixme check if `@as(u16, bytes[12]) << 8)` works as expected
        const crc = if (header_size == MAX_HEADER_SIZE) (@as(u16, bytes[13]) << 8) | (@as(u16, bytes[12])) else 0;
        return .{
            .header_size = header_size,
            .protocol_version = bytes[1],
            .profile_version = (@as(u16, bytes[3]) << 8) | (@as(u16, bytes[2])),
            .data_size = (@as(u32, bytes[7]) << 24) | (@as(u32, bytes[6]) << 16) | (@as(u32, bytes[5]) << 8) | @as(u32, bytes[4]),
            // fixme is it possible to use slice here?
            .data_type = [_]u8{
                bytes[8],
                bytes[9],
                bytes[10],
                bytes[11],
            },
            .crc = crc,
        };
    }

    pub fn print(header: *const FitFileHeader) void {
        const p = std.debug.print;
        p("FitFileHeader [\n", .{});
        p("\theader_size = {d}\n", .{header.header_size});
        p("\tprotocol_version = {d}\n", .{header.protocol_version});
        p("\tprofile_version = {d}\n", .{header.profile_version});
        p("\tdata_size = {d}\n", .{header.data_size});
        p("\tdata_type = {s}\n", .{header.data_type});
        p("\tcrc = {d}\n", .{header.crc});
        p("]\n", .{});
    }
};

const MessageType = enum {
    // In a definition message, the local message type is assigned to a Global FIT Message Number (mesg_num)
    // relating the local messages to their respective FIT messages
    definition,
    // The local message type associates a data message to its respective definition message,
    // and hence, its' global FIT message. A data message will follow the format as specified
    // in its definition message of matching local message type.
    data,
};

const FitRecordHeaderType = enum {
    normal,
    compressed_timestamp,
};

const FitRecordHeader = struct {
    data: u8,
    local_message_type: u4,
    dev_data_flag: u1,
    message_type: MessageType,
    type: FitRecordHeaderType,

    pub fn create(data: u8) FitRecordHeader {
        const lmt: u4 = @intCast(data & 0b1111);
        const dev_flag: u1 = @intCast((data >> 5) & 1);
        const message_type = (data >> 6) & 1;
        const header_type = (data >> 7) & 1;

        return .{
            .data = data,
            .local_message_type = lmt,
            .dev_data_flag = dev_flag,
            .message_type = if (message_type == 1) MessageType.definition else MessageType.data,
            .type = if (header_type == 0) FitRecordHeaderType.normal else FitRecordHeaderType.compressed_timestamp,
        };
    }

    pub fn print(header: *const FitRecordHeader) void {
        const p = std.debug.print;
        p("FitRecordHeader [\n", .{});
        p("\tdata = {d}\n", .{header.data});
        p("\tlocal_message_type = {d}\n", .{header.local_message_type});
        p("\tdev_data_flag = {d}\n", .{header.dev_data_flag});
        p("\tmessage_type = {s}\n", .{@tagName(header.message_type)});
        p("\ttype = {s}\n", .{@tagName(header.type)});
        p("]\n", .{});
    }
};

// [14, 16, 242, 3, 205, 31, 1, 0, 46, 70, 73, 84, 241, 165, ]

fn workload() !bool {
    const file = try fs.openFileAbsolute(fit_file, .{});
    defer file.close();

    var header_bytes: [MAX_HEADER_SIZE]u8 = undefined;
    _ = try file.read(&header_bytes);
    const file_header = FitFileHeader.createFromBytes(header_bytes);
    file_header.print();

    // record header
    var record_header_bytes: [1]u8 = undefined;
    _ = try file.read(&record_header_bytes);
    const record_header = FitRecordHeader.create(record_header_bytes[0]);
    record_header.print();

    // record content
    try readRecordContent(&file);

    // second record
    _ = try file.read(&record_header_bytes);
    const record_header2 = FitRecordHeader.create(record_header_bytes[0]);
    print("RECORD HEADER 2:\n", .{});
    record_header2.print();

    // read_bytes = try file.read(&header_bytes);
    // print("read again 1: {d}\n", .{read_bytes});
    // for (header_bytes) |byte| {
    //     print("{d} ", .{byte});
    // }
    // print("\n", .{});
    //
    return true;
}

const Architecture = enum {
    big_endian,
    little_endian,
};

const FieldDefinition = struct {
    // The Field Definition Number uniquely identifies a specific FIT field of the given FIT message.
    // The field definition numbers for each global FIT message are provided in the SDK. 255 represents an invalid field number.
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
    // endian_ability: bool,

    fn getBaseTypeNum(fd: *const FieldDefinition) u5 {
        return @intCast(fd.base_type >> 3);
    }

    fn create(data: [3]u8) FieldDefinition {
        return .{
            .field_def_number = data[0],
            .size = data[1],
            .base_type = data[2],
            // .base_type = @intCast(data[2] >> 3),
            // .endian_ability = data[2] & 1 == 1,
        };
    }

    fn print(fd: *const FieldDefinition) void {
        std.debug.print("Field Definition [\n", .{});
        std.debug.print("\tfield_def_number = {d}\n", .{fd.field_def_number});
        std.debug.print("\tsize = {d}\n", .{fd.size});
        std.debug.print("\tbase_type = {d}\n", .{fd.base_type});
        // std.debug.print("\tendian_ability = {}\n", .{fd.endian_ability});
        std.debug.print("]\n", .{});
    }
};

const FitRecord = struct {
    header: FitRecordHeader,
    content: FitRecordContent,
};

const FitRecordContent = struct {
    arch: Architecture,
    global_message_number: u16,
    field_count: u8,
};

const fit_protocol = @import("fit_protocol.zig");
const Fit = fit_protocol.Fit;

test "fit test" {
    var r: Fit.Record = undefined;
    r = .{ .a = 100, .header = Fit.Record.Header{ .h = 12, .type = Fit.Record.Header.Type.normal } };
    try std.testing.expect(r.a == 100);
    try std.testing.expect(r.header.h == 12);
    try std.testing.expect(r.header.type == Fit.Record.Header.Type.normal);
}

// fn readFitRecord(file: *const fs.File) !FitRecord {
//     const record: FitRecord = undefined;

//     var record_header_bytes: [1]u8 = undefined;
//     _ = try file.read(&record_header_bytes);
//     const header = FitRecordHeader.create(record_header_bytes[0]);
// }

fn readRecordContent(alloc: std.mem.Allocator, file: *const fs.File) !void {
    var record_content_fixed: [5]u8 = undefined;
    _ = try file.read(&record_content_fixed);
    const architecture = record_content_fixed[1];
    const global_message_number = @as(u16, record_content_fixed[2]) << 8 | record_content_fixed[3];
    const fields_count = record_content_fixed[4];

    print("Record content fixed:\n", .{});
    print("\treserved = {d}\n", .{record_content_fixed[0]});
    print("\tarchitecture = {d}\n", .{architecture});
    print("\tglobal message number = {d}\n", .{global_message_number});
    print("\tnumber of fields = {d}\n", .{fields_count});

    var field_def: [3]u8 = undefined;
    const fields = std.ArrayList(FieldDefinition).init(alloc);
    for (0..fields_count) |_| {
        _ = try file.read(&field_def);
        const fd = FieldDefinition.create(field_def);
        try fields.append(fd);
        // const fd = FieldDefinition{
        //     .field_def_number = field_def[0],
        //     .size = field_def[1],
        //     .base_type = field_def[2],
        // };
        fd.print();
    }

    // try readRecordFields(file, fields_count);
}

fn readRecordFields(file: *const fs.File, fields_count: u8) !void {
    var field_def: [3]u8 = undefined;
    for (0..fields_count) |_| {
        _ = try file.read(&field_def);
        const fd = FieldDefinition.create(field_def);
        // const fd = FieldDefinition{
        //     .field_def_number = field_def[0],
        //     .size = field_def[1],
        //     .base_type = field_def[2],
        // };
        fd.print();
    }
}

test "check smth" {
    const file = try fs.openFileAbsolute("/home/ihor/code/zig-plgrnd/test.txt", .{});
    var hel: [3]u8 = undefined;
    _ = try file.read(&hel);
    var lo: [2]u8 = undefined;
    _ = try file.read(&lo);
    print("{s}{s}\n", .{ hel, lo });
    try testing.expect(true);
}

fn readHeader(fit_file_path: []const u8) ![MAX_HEADER_SIZE]u8 {
    const file = try fs.openFileAbsolute(fit_file_path, .{});
    defer file.close();
    var header_bytes: [MAX_HEADER_SIZE]u8 = undefined;
    const read_bytes = try file.read(&header_bytes);
    assert(read_bytes == MAX_HEADER_SIZE);
    return header_bytes;
}

test "wip" {
    // const header_bytes = try readHeader(fit_file);
    // const header = FitFileHeader.createFromBytes(header_bytes);
    const res = try workload();
    // file_header.print();
    // record_header.print();
    // try testing.expect(std.mem.eql(u8, ".FIT", &file_header.data_type));
    try testing.expect(res);
}

test "creates record header from a byte" {
    var byte: u8 = 0b01000110;
    var header = FitRecordHeader.create(byte);
    try testing.expectEqual(0b0110, header.local_message_type);
    try testing.expectEqual(0, header.dev_data_flag);
    try testing.expectEqual(MessageType.definition, header.message_type);
    try testing.expectEqual(FitRecordHeaderType.normal, header.type);

    byte = 0b10101010;
    header = FitRecordHeader.create(byte);
    try testing.expectEqual(0b1010, header.local_message_type);
    try testing.expectEqual(1, header.dev_data_flag);
    try testing.expectEqual(MessageType.data, header.message_type);
    try testing.expectEqual(FitRecordHeaderType.compressed_timestamp, header.type);
}

// test "wip2" {
//     const header_bytes = try readHeader(fit_file);
//     const str = [_]u8{
//         header_bytes[8],
//         header_bytes[9],
//         header_bytes[10],
//         header_bytes[11],
//     };
//     print("{s}\n", .{str});
//     print("{d}\n", .{header_bytes[10]});
//     try testing.expect(4 == 4);
// }

// test "bytes" {
//     var data: u8 = 0b10100100;
//     var mts = (data >> 2) & 1;
//     print("mts = {d}\n", .{mts});
//     try testing.expect(mts == 1);

//     data = 0b10100000;
//     mts = (data >> 2) & 1;
//     print("mts = {d}\n", .{mts});
//     try testing.expect(mts == 0);
// }

fn printArray(arr: []u8) void {
    print("[", .{});
    for (arr) |item| {
        print("{d}, ", .{item});
    }
    print("]", .{});
}
