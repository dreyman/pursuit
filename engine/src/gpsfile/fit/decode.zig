const std = @import("std");
const mem = std.mem;
const Endian = std.builtin.Endian;
const assert = std.debug.assert;
const print = std.debug.print;

const fit = @import("fit_protocol.zig");
const Fit = fit.Fit;
const profile = @import("profile.zig");
const fit_debug = @import("debug.zig");

pub const DecodeError = error{
    InvalidFitFile,
    InvalidFitHeader,
    InvalidArchitectureValue,
    DataWithoutDefinition,
};

pub const Result = struct {
    lat: []f32,
    lon: []f32,
    time: []u32,
    temperature: ?[]i8,
    altitude: ?[]i32,
};

// fixme check array boundaries
pub fn decode(alloc: std.mem.Allocator, fit_bytes: []const u8) DecodeError!Fit {
    if (fit_bytes.len < fit.header_len_min) return DecodeError.InvalidFitFile;
    const header_size = fit_bytes[0];
    if (header_size != fit.header_len_min and header_size != fit.header_len_max) {
        return DecodeError.InvalidFitHeader;
    }
    const fit_header: fit.Header = .{ .bytes = fit_bytes[0..header_size] };
    var definitions = std.AutoHashMap(u4, fit.Message.Definition).init(alloc);
    defer {
        var it = definitions.valueIterator();
        while (it.next()) |def| {
            alloc.free(def.fields);
            alloc.free(def.dev_fields);
        }
        definitions.deinit();
    }
    var messages = std.ArrayList(fit.Message.Data).init(alloc);
    errdefer {
        for (messages.items) |mesg| {
            alloc.free(mesg.fields);
        }
        messages.deinit();
    }
    if (fit_bytes.len < fit_header.size() + fit_header.dataSize()) {
        return DecodeError.InvalidFitFile;
    }

    var pos: usize = header_size;
    var size: usize = undefined;
    while (pos < fit_bytes.len - 2) {
        const header: fit.Message.Header = .{ .byte = fit_bytes[pos] };
        pos += 1;
        switch (header.messageType()) {
            .definition => {
                size, const def = try decodeDefinitionMessage(alloc, header, fit_bytes[pos..]);
                pos += size;
                const item = definitions.get(def.local_id);
                if (item != null) {
                    alloc.free(item.?.fields);
                    alloc.free(item.?.dev_fields);
                }
                definitions.put(def.local_id, def) catch unreachable;
            },
            .data => {
                const definition = definitions.get(header.localId()) orelse
                    return DecodeError.DataWithoutDefinition;
                size, const mesg = try decodeFitDataMessage(alloc, fit_bytes[pos..], definition);
                pos += size;
                messages.append(mesg) catch unreachable;
            },
        }
    }
    return .{
        .alloc = alloc,
        .bytes = fit_bytes,
        .header = fit_header,
        .messages = messages,
    };
}

pub fn decodeDefinitionMessage(
    alloc: mem.Allocator,
    header: fit.Message.Header,
    bytes: []const u8,
) DecodeError!struct { usize, fit.Message.Definition } {
    _ = bytes[0]; // reserved
    const arch = bytes[1];
    if (arch > 1) return DecodeError.InvalidArchitectureValue;
    const endianess: std.builtin.Endian = if (arch == 0) .little else .big;
    const global_id = std.mem.readVarInt(u16, bytes[2..4], endianess);

    const fields_count = bytes[4];
    var pos: usize = 5;
    const field_defs = decodeFieldDefinitions(alloc, bytes[pos..], fields_count);
    errdefer alloc.free(field_defs);
    pos += field_defs.len * fit.field_definition_bytes_len;

    const dev_fields_count = if (header.containsDevData()) bytes[pos] else 0;
    if (dev_fields_count > 0) pos += 1;
    const dev_field_defs = decodeFieldDefinitions(alloc, bytes[pos..], dev_fields_count);
    errdefer alloc.free(dev_field_defs);
    pos += dev_field_defs.len * fit.field_definition_bytes_len;

    return .{ pos, .{
        .fields = field_defs,
        .dev_fields = dev_field_defs,
        .arch = endianess,
        .global_id = global_id,
        .local_id = header.localId(),
    } };
}

pub fn decodeDataMessageFields(
    alloc: std.mem.Allocator,
    field_definitions: []const fit.Message.Definition.Field,
    dev_field_definitions: []const fit.Message.Definition.Field,
    bytes: []const u8,
) struct { usize, []const fit.Message.Data.Field } {
    var fields = alloc.alloc(
        fit.Message.Data.Field,
        field_definitions.len + dev_field_definitions.len,
    ) catch unreachable;
    var pos: usize = 0;
    var idx: usize = 0;
    for (field_definitions) |field_def| {
        fields[idx] = .{ .data = bytes[pos .. pos + field_def.size] };
        idx += 1;
        pos += field_def.size;
    }
    for (dev_field_definitions) |field_def| {
        fields[idx] = .{ .data = bytes[pos .. pos + field_def.size] };
        idx += 1;
        pos += field_def.size;
    }
    return .{ pos, fields };
}

pub fn decodeFieldDefinitions(
    alloc: std.mem.Allocator,
    bytes: []const u8,
    count: u8,
) []fit.Message.Definition.Field {
    assert(bytes.len >= count * fit.field_definition_bytes_len);

    var defs = alloc.alloc(fit.Message.Definition.Field, count) catch unreachable;
    errdefer alloc.free(defs);
    for (0..count) |idx| {
        const pos = idx * fit.field_definition_bytes_len;
        defs[idx] = .{
            .id = bytes[pos],
            .size = bytes[pos + 1],
            .base_type = bytes[pos + 2],
        };
    }
    return defs;
}

pub fn decodeFitDataMessage(
    alloc: std.mem.Allocator,
    fit_bytes: []const u8,
    definition: fit.Message.Definition,
) !struct { usize, fit.Message.Data } {
    // fixme check array boundaries
    // fixme get rid of usize return, size can be calculated from definition
    var fields = alloc.alloc(
        fit.Message.Data.Field,
        definition.fields.len + definition.dev_fields.len,
    ) catch unreachable;
    errdefer alloc.free(fields);
    var pos: usize = 0;
    for (definition.fields, 0..) |field_def, idx| {
        fields[idx] = .{
            .id = field_def.id,
            .base_type = field_def.base_type,
            .val = fit_bytes[pos .. pos + field_def.size],
        };
        pos += field_def.size;
    }
    for (definition.dev_fields, 0..) |field_def, idx| {
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
