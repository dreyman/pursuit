const std = @import("std");
const p = std.debug.print;
const fit = @import("fit_protocol.zig");
const profile = @import("profile.zig");

pub fn printAsJson(prefix: []const u8, val: anytype) void {
    p("{s} {}\n", .{ prefix, std.json.fmt(val, .{ .whitespace = .indent_4 }) });
}

pub fn printFitHeader(header: fit.Header) void {
    p("Fit Header \\{", .{});
    p("\tsize = {d}", .{header.size()});
    p("\tprotocol_version = {d}", .{header.protocolVersion()});
    p("\tprofile_version = {d}", .{header.profileVersion()});
    p("\tdata_size = {d}", .{header.dataSize()});
    p("\\}\n", .{});
}

pub fn printMessageHeader(header: fit.Message.Header) void {
    p("Message Header [\n", .{});
    p("\ttype = {s}\n", .{@tagName(header.messageType())});
    p("\tdev_data = {s}\n", .{if (header.containsDevData()) "true" else "false"});
    p("\tlocal_id = {d}\n", .{header.localId()});
    p("]\n", .{});
}

pub fn printDefinitionMessageSimple(def: fit.Fit.Message.Definition) void {
    p("Definition {d}: fields={d}, dev={d}, GMT={d}, type={s}\n", .{
        def.local_id,
        def.fields.len,
        def.dev_fields.len,
        def.global_id,
        profile.getMessageName(def.global_id),
    });
}

pub fn printDefinitionMessage(def: fit.Message.Definition) void {
    p("Definition Message [\n", .{});
    p("\tarch = {s}\n", .{@tagName(def.arch)});
    p("\tglobal_id = {d}\n", .{def.global_id});
    p("\tlocal_id = {d}\n", .{def.local_id});
    p("\tfields = {d}\n", .{def.fields.len});
    p("\tdev_fields = {d}\n", .{def.dev_fields.len});
    p("]\n", .{});
}
