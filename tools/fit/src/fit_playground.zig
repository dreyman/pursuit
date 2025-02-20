const std = @import("std");
const print = std.debug.print;
const fs = std.fs;
const t = std.testing;
const assert = std.debug.assert;

const fit = @import("fit_protocol.zig");
const Fit = fit.Fit;
const fit_profile = @import("fit_profile.zig");

const util = @import("util.zig");

const fit_file = "/home/ihor/code/zig-plgrnd/example.fit";

fn just(alloc: std.mem.Allocator) !u8 {
    const file = try fs.openFileAbsolute(fit_file, .{});
    defer file.close();

    const FIT_DATA_SIZE = 10_000;
    var fit_data: [FIT_DATA_SIZE]u8 = undefined;
    const read_count = try file.read(&fit_data);
    assert(read_count == FIT_DATA_SIZE);

    var pos: usize = 0;
    var size: usize = undefined;

    size, const fit_header = fit.createFitHeader(&fit_data);
    pos += size;

    const record_header = fit.createRecordHeader(fit_data[pos]);
    pos += 1;

    const arch = fit_data[pos + 1];
    var global_message_number = @as(u16, fit_data[pos + 2]) << 8 | fit_data[pos + 3];
    if (arch == 0) global_message_number = @byteSwap(global_message_number);
    const fields_count = fit_data[pos + 4];
    pos += 5;

    var field_defs = std.ArrayList(SimpleFieldDef).init(alloc);
    defer field_defs.deinit();
    for (0..fields_count) |_| {
        try field_defs.append(.{
            .def_num = fit_data[pos],
            .size = fit_data[pos + 1],
            .base_type = fit_data[pos + 2],
        });
        pos += 3;
        // print("Field Def {d} [\n", .{idx + 1});
        // print("\tdef_num   = {d}\n", .{field_def1});
        // print("\tsize      = {d}\n", .{field_def2});
        // print("\tbase_type = {d}\n", .{field_def3});
        // print("]\n", .{});
    }

    const record_header2 = fit.createRecordHeader(fit_data[pos]);
    pos += 1;

    var data_fields = std.ArrayList(SimpleFieldData).init(alloc);
    defer data_fields.deinit();
    for (field_defs.items) |def| {
        try data_fields.append(.{ .data = fit_data[pos .. pos + def.size] });
        pos += def.size;
    }

    const record_header3 = fit.createRecordHeader(fit_data[pos]);
    pos += 1;

    util.printFitHeader(&fit_header);
    util.printRecordHeader(&record_header);
    printContentHeader(arch, global_message_number, fields_count);
    util.printRecordHeader(&record_header2);
    util.printRecordHeader(&record_header3);

    // for (field_defs.items, 0..) |def, idx| {
    //     const value = data_fields.items[idx].getValue(if (arch == 0) .little else .big);
    //     print("Field [\n", .{});
    //     print("\tdef_num   = {d}\n", .{def.def_num});
    //     print("\tsize      = {d}\n", .{def.size});
    //     print("\tbase_type = {d}\n", .{def.base_type});
    //     print("\tvalue     = {d}\n", .{value});
    //     print("]\n", .{});
    // }

    return 69;
}

pub const SimpleFieldData = struct {
    data: []u8,

    pub fn getValue(self: *const SimpleFieldData, endian: std.builtin.Endian) u64 {
        return std.mem.readVarInt(u64, self.data, endian);
        // var res: u64 = 0;
        // var shift: u6 = 0;
        // var idx: usize = self.data.len;
        // while (idx > 0) : (idx -= 1) {
        //     res = (res << shift) | self.data[idx - 1];
        //     shift += 8;
        // }
        // return res;
    }
};

pub const SimpleFieldDef = struct {
    def_num: u8,
    size: u8,
    base_type: u8,
};

fn printContentHeader(arch: u8, gmn: u16, fields_count: u8) void {
    print("Record Content Meta [\n", .{});
    print("\tarchitecture = {d}\n", .{arch});
    print("\tglobal_message_number = {d}\n", .{gmn});
    print("\tfields_count = {d}\n", .{fields_count});
    print("]\n", .{});
}

fn parseFitFile(alloc: std.mem.Allocator, file: *const fs.File) !Fit {
    var header_bytes: [fit.fit_header_len_min]u8 = undefined;
    var read_count = try file.read(&header_bytes);
    assert(read_count == header_bytes.len);

    _, const fit_header = fit.createFitHeader(&header_bytes);
    assert(fit_header.size == 12 or fit_header.size == 14);

    const fit_data_size = if (fit_header.size == 14) fit_header.data_size + 2 else fit_header.data_size;
    var fit_bytes = try alloc.alloc(u8, fit_data_size);
    defer alloc.free(fit_bytes);

    read_count = try file.read(fit_bytes);
    assert(read_count == fit_data_size);

    var records = std.ArrayList(Fit.Record).init(alloc);
    var pos: usize = if (fit_header.size == fit.fit_header_len_max) 2 else 0;
    var size: usize = undefined;
    while (pos < fit_bytes.len - 2) {
        const record_header = fit.createRecordHeader(fit_bytes[pos]);
        pos += 1;
        var def: ?Fit.Record.Definition = null;
        if (record_header.record_type == .data) {
            for (records.items) |rec| {
                if (rec.header.record_type == .definition and rec.header.local_message_type == record_header.local_message_type) {
                    def = rec.content.definition;
                }
            }
            assert(def != null);
        }
        var content: Fit.Record.Content = undefined;
        switch (record_header.record_type) {
            .definition => {
                size, content = try parseDefinitionRecordContent(
                    alloc,
                    fit_bytes[pos..],
                    record_header.contains_dev_data,
                );
            },
            .data => {
                size, content = try parseDataRecordContent(
                    alloc,
                    fit_bytes[pos..],
                    def.?.field_definitions.items,
                );
            },
        }
        pos += size;

        // size, const record = try parseFitRecord(alloc, fit_data[pos..], curr_definitions);
        // pos += size;
        try records.append(.{ .header = record_header, .content = content });
        // if (record.header.record_type == .definition) {
        //     curr_definitions = record.content.definition.field_definitions.items;
        // }
    }

    // print("parsing {d}\n", .{RECORDS_COUNT + 1});
    // size, const record = try parseFitRecord(alloc, fit_data[pos..], curr_definitions);
    // pos += size;
    // try records.append(record);

    return .{ .header = fit_header, .records = records };
}

test "parses fit file" {
    const alloc = std.testing.allocator;
    const file = try fs.openFileAbsolute(fit_file, .{});
    defer file.close();

    const fit_data = try parseFitFile(alloc, &file);
    defer fit_data.deinit();

    print("HEADER SIZE: {d}\n", .{fit_data.header.size});
    print("DATA SIZE: {d}\n", .{fit_data.header.data_size});

    // util.printFitHeader(&fit_data.header);
    // util.printRecordHeader(&fit_data.record1.header);
    // util.printRecordContent(&fit_data.record1.content);
    // var data_records: u32 = 0;
    // var other_data_records: u32 = 0;
    var data_records = std.AutoHashMap(u16, u32).init(std.testing.allocator);
    defer data_records.deinit();
    for (fit_data.records.items, 1..) |record, idx| {
        // util.printRecordSimple(&record, idx);
        if (record.header.record_type == .data) {
            const lmt = record.header.local_message_type;
            var gmt: ?u16 = null;
            for (fit_data.records.items) |rec| {
                if (rec.header.record_type == .definition and rec.header.local_message_type == lmt) {
                    gmt = rec.content.definition.global_message_number;
                }
            }
            assert(gmt != null);
            const count = data_records.get(gmt.?);
            try data_records.put(gmt.?, if (count != null) count.? + 1 else 1);
        } else {
            util.printRecordSimple(&record, idx);
        }
    }
    var iterator = data_records.iterator();
    while (iterator.next()) |entry| {
        print("\nDATA RECORDS {s}: {d}", .{
            fit_profile.getMessageName(entry.key_ptr.*),
            entry.value_ptr.*,
        });
    }
    // print("\nDATA RECORDS COUNT: {d}", .{data_records});
    // print("\nOTHER DATA RECORDS COUNT: {d}", .{other_data_records});
    // util.printRecordSimple("Record 1: ", &fit_data.record1);
    // util.printRecordSimple("Record 2: ", &fit_data.record2);
    // util.printRecordSimple("Record 3: ", &fit_data.record3);
    // util.printRecordSimple("Record 3: ", &fit_data.record4);

    std.debug.print("\n", .{});

    // for (fit_data.records.items) |rec| {
    //     if (rec.header.record_type == .definition) {
    //         print("\t\tGMN = {d}\n", .{rec.content.definition.global_message_number});
    //     }
    //     // if (rec.header.record_type == .definition and rec.header.local_message_type < 3) {
    //     //     util.printRecordDefinitionContent(&rec.content.definition);
    //     //     // for (rec.content.definition.field_definitions.items) |fd| {
    //     //     //     util.printFieldDefinition(&fd);
    //     //     // }
    //     // }
    // }

    try t.expect(fit_data.header.size == 14);
    // try t.expect(fit_data.record1.header.type == Fit.Record.Header.Type.normal);
    // try t.expect(fit_data.record1.header.record_type == Fit.Record.Type.definition);
    // try t.expect(fit_data.record2.header.type == Fit.Record.Header.Type.normal);
    // try t.expect(fit_data.record2.header.record_type == Fit.Record.Type.data);
}

fn parseFitRecord(
    alloc: std.mem.Allocator,
    bytes: []u8,
    definitions: []Fit.Record.Definition.Field,
) !struct { usize, Fit.Record } {
    const record_header = fit.createRecordHeader(bytes[0]);
    var content: Fit.Record.Content = undefined;
    var size: usize = undefined;
    switch (record_header.record_type) {
        .definition => {
            size, content = try parseDefinitionRecordContent(alloc, bytes[1..], record_header.contains_dev_data);
        },
        .data => {
            size, content = try parseDataRecordContent(alloc, bytes[1..], definitions);
        },
    }
    return .{ size + 1, .{ .header = record_header, .content = content } };
}

fn parseDataRecordContent(
    alloc: std.mem.Allocator,
    bytes: []u8,
    definitions: []Fit.Record.Definition.Field,
) !struct { usize, Fit.Record.Content } {
    var fields = try std.ArrayList(Fit.Record.Data.Field).initCapacity(alloc, definitions.len);
    var pos: usize = 0;
    for (definitions) |definition| {
        try fields.append(.{
            .data = bytes[pos .. pos + definition.size],
            .definition = definition,
        });
        pos += definition.size;
    }
    return .{ pos, .{ .data = .{ .fields = fields } } };
}

fn parseDefinitionRecordContent(
    alloc: std.mem.Allocator,
    bytes: []u8,
    contains_dev_data: bool,
) !struct { usize, Fit.Record.Content } {
    _ = bytes[0]; // reserved
    const architecture = bytes[1];
    // const global_message_number = @as(u16, bytes[2]) << 8 | bytes[3];
    const global_message_number = std.mem.readVarInt(
        u16,
        bytes[2..3],
        if (architecture == 0) .little else .big,
    );
    const fields_count = bytes[4];
    assert(architecture == 0 or architecture == 1);
    var pos: usize = 5;

    var field_definitions = try std.ArrayList(Fit.Record.Definition.Field).initCapacity(alloc, fields_count);
    for (0..fields_count) |_| {
        const def_num = bytes[pos];
        try field_definitions.append(.{
            .field_def_number = def_num,
            .size = bytes[pos + 1],
            .base_type = bytes[pos + 2],
        });
        pos += 3;
    }
    var dev_field_definitions: ?std.ArrayList(Fit.Record.Definition.Field) = null;
    if (contains_dev_data) {
        print("\ndev data\n", .{});
        const dev_fields_count = bytes[pos];
        pos += 1;
        assert(dev_fields_count > 0);
        pos, dev_field_definitions = try parseDevFieldDefinitions(alloc, bytes[pos..], dev_fields_count);
    }
    return .{ pos, .{ .definition = .{
        .arch = if (architecture == 0) .little else .big,
        .global_message_number = global_message_number,
        .fields_count = fields_count,
        .field_definitions = field_definitions,
        .dev_field_definitions = dev_field_definitions,
    } } };
}

fn parseDevFieldDefinitions(
    alloc: std.mem.Allocator,
    bytes: []u8,
    fields_count: u8,
) !struct { usize, std.ArrayList(Fit.Record.Definition.Field) } {
    assert(fields_count > 0);
    var field_definitions = try std.ArrayList(Fit.Record.Definition.Field).initCapacity(alloc, fields_count);
    for (0..fields_count) |_| {
        try field_definitions.append(undefined);
    }
    var pos: usize = 0;
    for (0..fields_count) |_| {
        const def_num = bytes[pos];
        field_definitions.items[def_num] = .{
            .field_def_number = def_num,
            .size = bytes[pos + 1],
            .base_type = bytes[pos + 2],
            .dev = true,
        };
        pos += 3;
    }
    return .{ pos, field_definitions };
}
