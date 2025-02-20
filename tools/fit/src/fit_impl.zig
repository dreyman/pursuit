const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;
const fs = std.fs;
const t = std.testing;
const fitp = @import("fit_protocol.zig");
const RawFit = fitp.RawFit;
const FitData = fitp.FitData;
const util = @import("util.zig");
const fit_debug = @import("debug.zig");
const profile = @import("fit_profile.zig");
const base_type = @import("base_type.zig");

pub const Error = error{
    InvalidFitHeader,
    InvalidArchitectureValue,
    DefinitionNotFound,
};

test "new approach" {
    const bytes = try util.fileAsBytes(t.allocator, "/home/ihor/code/zig-plgrnd/example.fit");
    defer t.allocator.free(bytes);

    var fit = try createFitData(t.allocator, bytes);
    defer fit.deinit();

    for (fit.messages.items) |mesg| {
        print("{s}({d}): {d}\n", .{
            profile.getMessageName(mesg.global_id),
            mesg.global_id,
            mesg.fields.len,
        });
    }

    try t.expect(fit.header.size() == 14);
}

pub fn createFitData(alloc: std.mem.Allocator, fit_bytes: []const u8) !FitData {
    const header_size = fit_bytes[0];
    if (header_size != fitp.fit_header_len_min and header_size != fitp.fit_header_len_max) {
        return Error.InvalidFitHeader;
    }
    const fit_header: RawFit.Header = .{ .bytes = fit_bytes[0..header_size] };
    var definitions = std.AutoHashMap(u4, RawFit.Message.Definition).init(alloc);
    var messages = std.ArrayList(FitData.Message).init(alloc);
    defer {
        var it = definitions.valueIterator();
        while (it.next()) |def| {
            alloc.free(def.fields);
            alloc.free(def.dev_fields);
        }
        definitions.deinit();
    }
    errdefer messages.deinit();
    if (fit_bytes.len < fit_header.size() + fit_header.dataSize()) {
        return Error.InvalidFitHeader;
    }

    var pos: usize = header_size;
    var size: usize = undefined;
    while (pos < 300) { //fit_bytes.len - 2) {
        const header: RawFit.Message.Header = .{ .byte = fit_bytes[pos] };
        pos += 1;
        switch (header.messageType()) {
            .definition => {
                size, const def = try decodeDefinitionMessage(alloc, header, fit_bytes[pos..]);
                pos += size;
                definitions.put(def.local_id, def) catch unreachable;
            },
            .data => {
                const definition = definitions.get(header.localId()) orelse return Error.DefinitionNotFound;
                size, const mesg = try decodeFitDataMessage(alloc, fit_bytes[pos..], definition);
                pos += size;
                messages.append(mesg) catch unreachable;
            },
        }
    }
    return .{
        .alloc = alloc,
        .header = fit_header,
        .messages = messages,
    };
}

fn decodeFitDataMessage(
    alloc: std.mem.Allocator,
    fit_bytes: []const u8,
    definition: RawFit.Message.Definition,
) !struct { usize, FitData.Message } {
    var fields = alloc.alloc(FitData.Message.Field, definition.fields.len) catch unreachable;
    var pos: usize = 0;
    for (definition.fields, 0..) |field_def, idx| {
        fields[idx] = .{
            .id = field_def.id,
            .base_type = field_def.base_type,
            .val = fit_bytes[pos .. pos + field_def.size],
        };
        pos += field_def.size;
    }
    return .{ pos, .{
        .arch = definition.arch,
        .global_id = definition.global_id,
        .fields = fields,
    } };
}

pub fn decode(alloc: std.mem.Allocator, fit_bytes: []const u8) !RawFit {
    const header_size = fit_bytes[0];
    if (header_size != fitp.fit_header_len_min and header_size != fitp.fit_header_len_max) {
        return Error.InvalidFitHeader;
    }
    const fit_header: RawFit.Header = .{ .bytes = fit_bytes[0..header_size] };
    var fit: RawFit = .{
        .alloc = alloc,
        .protocol_version = fit_header.protocolVersion(),
        .profile_version = fit_header.profileVersion(),
        .data_size = fit_header.dataSize(),
        .messages = std.ArrayList(RawFit.Message.Data).init(alloc),
        .definitions = std.ArrayList(RawFit.Message.Definition).init(alloc),
    };
    errdefer fit.deinit();
    if (fit_bytes.len < fit_header.size() + fit_header.dataSize()) {
        return Error.InvalidFitHeader;
    }
    var pos: usize = header_size;
    var size: usize = undefined;
    while (pos < fit_bytes.len - 2) {
        const header: RawFit.Message.Header = .{ .byte = fit_bytes[pos] };
        pos += 1;
        switch (header.messageType()) {
            .definition => {
                size, const def = try decodeDefinitionMessage(alloc, header, fit_bytes[pos..]);
                pos += size;
                fit.definitions.append(def) catch unreachable;
            },
            .data => {
                // var def: ?RawFit.Message.Definition = null;
                // for (fit.definitions.items) |d| {
                //     if (d.local_id == header.localId()) def = d;
                // }
                const def = findDefinition(fit.definitions.items, header.localId());
                if (def == null) return Error.DefinitionNotFound;
                // const data_fields = decodeDataFields(alloc, def.fields.items, bytes[pos..]);
                // size, const data = try decodeDataMessage(alloc, &def.?, fit_bytes[pos..]);
                size, const data_fields = decodeDataMessageFields(
                    alloc,
                    def.?.fields,
                    def.?.dev_fields,
                    fit_bytes[pos..],
                );
                pos += size;
                // if (header.headerType() == .compressed_timestamp) data.timeOffset = header.timeOffset();
                fit.messages.append(.{
                    .header = header,
                    .fields = data_fields,
                    .definition = undefined,
                }) catch unreachable;
            },
        }
    }
    for (fit.messages.items) |mesg| {
        var m = mesg;
        const def = findDefinition(fit.definitions.items, mesg.header.localId());
        if (def == null) return Error.DefinitionNotFound;
        const d = def.?;
        m.definition = d;
    }
    for (fit.messages.items) |mesg| {
        if (mesg.header.localId() != 3 and mesg.header.localId() != 1) {
            print("\n\tdata: def: local={d}, global={d}", .{ mesg.definition.local_id, mesg.definition.global_id });
        }
    }
    return fit;
}

test "decoding" {
    const bytes = try util.fileAsBytes(t.allocator, "/home/ihor/code/zig-plgrnd/example.fit");
    defer t.allocator.free(bytes);

    const fit = try decode(t.allocator, bytes);
    defer fit.deinit();

    for (fit.definitions.items) |def| {
        fit_debug.printDefinitionMessageSimple(def);
    }
    var data_records = std.AutoHashMap(u16, u32).init(t.allocator);
    defer data_records.deinit();
    print("\n\n\t\tDATA RERCORDS LEN: {d}\n", .{fit.messages.items.len});
    for (fit.messages.items) |mesg| {
        const count = data_records.get(mesg.definition.global_id);
        if (count == null) {
            data_records.put(mesg.definition.global_id, 1) catch unreachable;
        } else {
            data_records.put(mesg.definition.global_id, count.? + 1) catch unreachable;
        }
    }
    var iterator = data_records.iterator();
    while (iterator.next()) |entry| {
        print("\nDATA RECORDS {s}: {d}", .{
            profile.getMessageName(entry.key_ptr.*),
            entry.value_ptr.*,
        });
    }
    for (fit.messages.items, 1..) |mesg, idx| {
        if (idx > 10) break;
        print("\nDATA MESG: {d} {s} fields={d}\n", .{
            mesg.definition.global_id,
            profile.getMessageName(mesg.definition.global_id),
            mesg.definition.fields.len,
        });
    }

    try t.expect(bytes[0] == 14);
}

fn decodeDataFields(
    alloc: std.mem.Allocator,
    field_defs: []const RawFit.Message.Definition.Field,
    bytes: []const u8,
) std.ArrayList(RawFit.Message.Data.Field) {
    var fields = std.ArrayList(RawFit.Message.Data.Field).initCapacity(alloc, field_defs.len) catch unreachable;
    var pos: usize = 0;
    for (field_defs) |def| {
        fields.append(.{
            .definition = &def,
            .data = bytes[pos .. pos + def.size],
        }) catch unreachable;
        pos += def.size;
    }
    return fields;
}

fn decodeDataMessageFields(
    alloc: std.mem.Allocator,
    // definition: *const RawFit.Message.Definition,
    field_definitions: []const RawFit.Message.Definition.Field,
    dev_field_definitions: []const RawFit.Message.Definition.Field,
    bytes: []const u8,
) struct { usize, []const RawFit.Message.Data.Field } {
    var fields = alloc.alloc(
        RawFit.Message.Data.Field,
        field_definitions.len + dev_field_definitions.len,
    ) catch unreachable;
    // var fields = try std.ArrayList(RawFit.Message.Data.Field)
    //     .initCapacity(alloc, definition.fields.items.len + definition.dev_fields.items.len);
    var pos: usize = 0;
    var idx: usize = 0;
    for (field_definitions) |field_def| {
        fields[idx] = .{
            .data = bytes[pos .. pos + field_def.size],
        };
        idx += 1;
        // try fields.append(.{
        //     .definition = &field_def,
        //     .data = bytes[pos .. pos + field_def.size],
        // });
        pos += field_def.size;
    }
    for (dev_field_definitions) |field_def| {
        fields[idx] = .{
            // .definition = &field_def,
            .data = bytes[pos .. pos + field_def.size],
        };
        idx += 1;
        // try fields.append(.{
        //     .definition = &field_def,
        //     .data = bytes[pos .. pos + field_def.size],
        // });
        pos += field_def.size;
    }
    return .{ pos, fields };
}

fn decodeDefinitionMessage(
    alloc: std.mem.Allocator,
    header: RawFit.Message.Header,
    bytes: []const u8,
) !struct { usize, RawFit.Message.Definition } {
    _ = bytes[0]; // reserved
    const arch = bytes[1];
    if (arch > 1) return Error.InvalidArchitectureValue;
    const endianess: std.builtin.Endian = if (arch == 0) .little else .big;
    const global_id = std.mem.readVarInt(u16, bytes[2..4], endianess);

    const fields_count = bytes[4];
    var pos: usize = 5;
    const field_defs = decodeFieldDefinitions(alloc, bytes[pos..], fields_count);
    pos += field_defs.len * fitp.field_definition_bytes_len;

    const dev_fields_count = if (header.containsDevData()) bytes[pos] else 0;
    // fixme: make sure for now that test fit file doesn't include dev fields; remove later
    assert(dev_fields_count == 0);
    if (dev_fields_count > 0) pos += 1;
    const dev_field_defs = decodeFieldDefinitions(alloc, bytes[pos..], dev_fields_count);
    pos += dev_field_defs.len * fitp.field_definition_bytes_len;

    return .{ pos, .{
        .fields = field_defs,
        .dev_fields = dev_field_defs,
        .arch = endianess,
        .global_id = global_id,
        .local_id = header.localId(),
    } };
}

fn decodeFieldDefinitions(
    alloc: std.mem.Allocator,
    bytes: []const u8,
    count: u8,
) []RawFit.Message.Definition.Field {
    assert(bytes.len >= count * fitp.field_definition_bytes_len);
    var defs = alloc.alloc(RawFit.Message.Definition.Field, count) catch unreachable;
    // var defs = try std.ArrayList(RawFit.Message.Definition.Field).initCapacity(alloc, count);
    // var pos: usize = 0;
    for (0..count) |idx| {
        const pos = idx * fitp.field_definition_bytes_len;
        defs[idx] = .{
            .id = bytes[pos],
            .size = bytes[pos + 1],
            .base_type = bytes[pos + 2],
        };
        // try defs.append(.{
        //     .id = bytes[pos],
        //     .size = bytes[pos + 1],
        //     .base_type = bytes[pos + 2],
        // });
        // pos += 3;
    }
    return defs;
}

fn findDefinition(
    defs: []const RawFit.Message.Definition,
    local_id: u4,
) ?*const RawFit.Message.Definition {
    for (defs) |def| {
        if (def.local_id == local_id) return &def;
    }
    return null;
}
