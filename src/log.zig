const std = @import("std");

pub const Level = enum {
    info,
    warn,
    err,

    pub fn toString(self: Level) []const u8 {
        return switch (self) {
            .info => "INFO",
            .warn => "WARN",
            .err => "ERROR",
        };
    }
};

/// Structured log entry: timestamp=<iso> level=<LEVEL> component=<comp> msg=<message>
/// Writes to stderr so stdout remains clean for user-facing output.
pub fn log(level: Level, component: []const u8, message: []const u8) void {
    var buf: [4096]u8 = undefined;
    var w = std.fs.File.stderr().writer(&buf);
    // Use epoch seconds as timestamp (portable)
    const ts = std.time.timestamp();
    w.interface.print("timestamp={d} level={s} component={s} msg={s}\n", .{
        ts,
        level.toString(),
        component,
        message,
    }) catch return;
    w.interface.flush() catch return;
}

pub fn info(component: []const u8, message: []const u8) void {
    log(.info, component, message);
}

pub fn warn(component: []const u8, message: []const u8) void {
    log(.warn, component, message);
}

pub fn err(component: []const u8, message: []const u8) void {
    log(.err, component, message);
}

test "log level toString" {
    try std.testing.expectEqualStrings("INFO", Level.info.toString());
    try std.testing.expectEqualStrings("WARN", Level.warn.toString());
    try std.testing.expectEqualStrings("ERROR", Level.err.toString());
}
