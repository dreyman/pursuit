const std = @import("std");
const p = std.debug.print;
const fit_protocol = @import("fit_protocol.zig");
const fit_profile = @import("fit_profile.zig");
const Fit = fit_protocol.Fit;

pub fn fileAsBytes(alloc: std.mem.Allocator, file_path: []const u8) ![]u8 {
    const file = try std.fs.openFileAbsolute(file_path, .{});
    defer file.close();

    const stat = try file.stat();
    const buf: []u8 = try file.readToEndAlloc(alloc, stat.size);
    return buf;
}

pub fn printRecordSimple(record: *const Fit.Record, idx: usize) void {
    switch (record.header.record_type) {
        .definition => printDefinitionRecordSimple(record, idx),
        .data => printDataRecordSimple(record, idx),
    }
}

pub fn printDefinitionRecordSimple(record: *const Fit.Record, idx: usize) void {
    const header_type = if (record.header.type == .normal) "N" else "C";
    const gmt = record.content.definition.global_message_number;
    // const mesg_type = std.meta.intToEnum(fit_profile.MesgNum, gmt) catch null;
    p("\tRecord {d}: [{s}] Defi {d}: fields={d}, dev={s}, GMT = {d}, type = {s}\n", .{
        idx,
        header_type,
        record.header.local_message_type,
        record.content.definition.field_definitions.items.len,
        if (record.header.contains_dev_data) "true" else "false",
        gmt,
        fit_profile.getMessageName(gmt),
    });
}

pub fn printDataRecordSimple(record: *const Fit.Record, idx: usize) void {
    const header_type = if (record.header.type == .normal) "N" else "C";
    p("Record {d}: [{s}] Data {d}: fields={d}, dev={s}\n", .{
        idx,
        header_type,
        record.header.local_message_type,
        record.content.data.fields.items.len,
        if (record.header.contains_dev_data) "true" else "false",
    });
}

pub fn printFitHeader(header: *const Fit.Header) void {
    p("FitFileHeader [\n", .{});
    p("\theader_size = {d}\n", .{header.size});
    p("\tprotocol_version = {d}\n", .{header.protocol_version});
    p("\tprofile_version = {d}\n", .{header.profile_version});
    p("\tdata_size = {d}\n", .{header.data_size});
    p("\tdata_type = {s}\n", .{header.data_type});
    p("\tcrc = {d}\n", .{header.crc});
    p("]\n", .{});
}

pub fn printRecordHeader(rh: *const Fit.Record.Header) void {
    p("FitRecordHeader [\n", .{});
    p("\tdata = {d}\n", .{rh.data});
    p("\tlocal_message_type = {d}\n", .{rh.local_message_type});
    p("\tcontains_dev_data = {s}\n", .{if (rh.contains_dev_data) "true" else "false"});
    p("\trecord_type = {s}\n", .{@tagName(rh.record_type)});
    p("\ttype = {s}\n", .{@tagName(rh.type)});
    p("]\n", .{});
}

// FIXME mb param shouldn't be pointer?
pub fn printRecordContent(content: *const Fit.Record.Content) void {
    switch (content.*) {
        .definition => |def| printRecordDefinitionContent(&def),
        .data => |data| printRecordDataContent(&data),
    }
}

pub fn printRecordDefinitionContent(def: *const Fit.Record.Definition) void {
    p("Record Definition [\n", .{});
    p("\tarchitecture = {s}\n", .{@tagName(def.arch)});
    p("\tglobal_message_number = {d}\n", .{def.global_message_number});
    p("\tfields_count = {d}\n", .{def.fields_count});
    p("\tfield_definitions.len = {d}\n", .{def.field_definitions.items.len});
    p("]\n", .{});
    for (def.field_definitions.items) |item| {
        printFieldDefinition(&item);
    }
}

pub fn printRecordDataContent(content: *const Fit.Record.Data) void {
    _ = content;
    unreachable;
}

pub fn printFieldDefinition(field_def: *const Fit.Record.Definition.Field) void {
    p("Field Definition [\n", .{});
    p("\tfield_def_number = {d}\n", .{field_def.field_def_number});
    p("\tsize = {d}\n", .{field_def.size});
    p("\tbase_type = {d}\n", .{field_def.base_type});
    p("]\n", .{});
}
