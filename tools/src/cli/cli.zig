const std = @import("std");
const assert = std.debug.assert;
const mem = std.mem;

pub fn processArgs(args: *std.process.ArgIterator) !void {
    assert(args.skip());
    const command = args.next() orelse {
        try write(help);
        return;
    };
    if (mem.eql(u8, command, "help")) {
        try write(help);
        return;
    }
    if (mem.eql(u8, command, "add")) {
        try write("not implemented yet");
        return;
    }
    if (mem.eql(u8, command, "init")) {
        try write("not implemented yet");
        return;
    }
    if (mem.eql(u8, command, "version")) {
        try write("0.0.1-wip");
        return;
    }

    try write(help);
}

pub const help =
    \\Usage:
    \\
    \\  wf version
    \\
    \\  wf help
    \\
    \\  wf init
    \\
    \\  wf add <path>
    \\
    \\Commands:
    \\
    \\  add        Add gps activity from the fit file at <path>.
    \\
    \\  version    Print the version.
    \\
    \\  init       Initialize wild fields app
;

// fn write(text: [:0]const u8) !void {
//     var stdout_buffer = std.io.bufferedWriter(std.io.getStdOut().writer());
//     var stdout_writer = stdout_buffer.writer();
//     const stdout = stdout_writer.any();

//     try std.fmt.format(stdout, "{s}\n", .{text});
//     try stdout_buffer.flush();
// }

fn write(text: [:0]const u8) !void {
    const out = std.io.getStdOut().writer();
    try out.print("{s}\n", .{text});
}
