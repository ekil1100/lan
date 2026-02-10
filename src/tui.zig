const std = @import("std");
const Agent = @import("agent.zig").Agent;

const Color = struct {
    const reset = "\x1b[0m";
    const green = "\x1b[32m";
    const yellow = "\x1b[33m";
    const cyan = "\x1b[36m";
    const bright_cyan = "\x1b[96m";
    const red = "\x1b[31m";
};

pub const App = struct {
    allocator: std.mem.Allocator,
    agent: *Agent,
    messages: std.array_list.Managed([]const u8),
    input_buffer: std.array_list.Managed(u8),

    pub fn init(allocator: std.mem.Allocator, agent: *Agent) !App {
        return App{
            .allocator = allocator,
            .agent = agent,
            .messages = std.array_list.Managed([]const u8).init(allocator),
            .input_buffer = std.array_list.Managed(u8).init(allocator),
        };
    }

    pub fn deinit(self: *App) void {
        for (self.messages.items) |msg| self.allocator.free(msg);
        self.messages.deinit();
        self.input_buffer.deinit();
    }

    pub fn run(self: *App) !void {
        const stdin = std.fs.File.stdin().deprecatedReader();
        const stdout = std.fs.File.stdout().deprecatedWriter();

        try stdout.writeAll(Color.cyan);
        try stdout.writeAll("╔══════════════════════════════════════╗\n");
        try stdout.writeAll("║  Lan Agent v0.3                      ║\n");
        try stdout.writeAll("╚══════════════════════════════════════╝\n");
        try stdout.writeAll(Color.reset);

        var buf: [4096]u8 = undefined;

        while (true) {
            try stdout.writeAll(Color.green);
            try stdout.writeAll("\n> ");
            try stdout.writeAll(Color.reset);

            const line = stdin.readUntilDelimiterOrEof(&buf, '\n') catch break;
            if (line == null) break;

            const trimmed = std.mem.trimRight(u8, line.?, "\r");
            if (trimmed.len == 0) continue;
            if (std.mem.eql(u8, trimmed, "/exit")) break;

            const response = self.agent.processInput(trimmed, stdout) catch |err| {
                try stdout.print(Color.red ++ "Error: {s}\n" ++ Color.reset, .{@errorName(err)});
                continue;
            };
            defer self.allocator.free(response);

            try stdout.writeAll(Color.yellow);
            try stdout.writeAll("* ");
            try stdout.writeAll(Color.reset);
            try stdout.writeAll(response);
            try stdout.writeByte('\n');
        }

        try stdout.writeByte('\n');
        try stdout.writeAll(Color.bright_cyan);
        try stdout.writeAll("Thanks for using Lan! Goodbye!\n\n");
        try stdout.writeAll(Color.reset);
    }
};