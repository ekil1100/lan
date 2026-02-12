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
    show_help: bool,

    pub fn init(allocator: std.mem.Allocator, agent: *Agent) !App {
        return App{
            .allocator = allocator,
            .agent = agent,
            .messages = std.array_list.Managed([]const u8).init(allocator),
            .input_buffer = std.array_list.Managed(u8).init(allocator),
            .show_help = false,
        };
    }

    pub fn deinit(self: *App) void {
        for (self.messages.items) |msg| self.allocator.free(msg);
        self.messages.deinit();
        self.input_buffer.deinit();
    }

    fn printHelp(writer: anytype) !void {
        try writer.writeAll(Color.cyan);
        try writer.writeAll("\n╔════════════════════════════════════════════════╗\n");
        try writer.writeAll("║  Lan TUI Shortcuts                             ║\n");
        try writer.writeAll("╚════════════════════════════════════════════════╝\n");
        try writer.writeAll(Color.reset);
        
        try writer.writeAll(Color.yellow);
        try writer.writeAll("\nCommands (type in chat):\n");
        try writer.writeAll(Color.reset);
        try writer.writeAll("  /help          Toggle this help\n");
        try writer.writeAll("  /clear         Clear chat history (keeps system message)\n");
        try writer.writeAll("  /exit          Exit Lan\n");
        
        try writer.writeAll(Color.yellow);
        try writer.writeAll("\nKeyboard Shortcuts:\n");
        try writer.writeAll(Color.reset);
        try writer.writeAll("  Ctrl+C         Exit\n");
        try writer.writeAll("  Ctrl+D         Exit (EOF)\n");
        try writer.writeAll("  Up/Down        Navigate history\n");
        try writer.writeAll("  Enter          Send message\n");
        
        try writer.writeAll(Color.yellow);
        try writer.writeAll("\nCLI Commands (outside TUI):\n");
        try writer.writeAll(Color.reset);
        try writer.writeAll("  lan skill list              List installed skills\n");
        try writer.writeAll("  lan skill search <kw>       Search skill registry\n");
        try writer.writeAll("  lan skill info <name>       Show skill details\n");
        try writer.writeAll("  lan history export          Export session history\n");
        try writer.writeAll("  lan history stats           Show history statistics\n");
        try writer.writeAll("  lan doctor                  Run diagnostics\n");
        try writer.writeAll(Color.yellow);
        try writer.writeAll("\nTip: AI responses stream in real-time.");
        try writer.writeAll(Color.reset);
        try writer.writeAll("\n\n");
    }

    fn printLoading(writer: anytype, message: []const u8) !void {
        try writer.writeAll(Color.yellow);
        try writer.writeAll("⏳ ");
        try writer.writeAll(message);
        try writer.writeAll("...");
        try writer.writeAll(Color.reset);
    }

    const ErrorClass = struct {
        label: []const u8,
        summary: []const u8,
        next_step: []const u8,
    };

    fn classifyError(err_name: []const u8) ErrorClass {
        if (std.mem.eql(u8, err_name, "NoAPIKey")) {
            return .{
                .label = "config",
                .summary = "missing API key",
                .next_step = "set MOONSHOT_API_KEY / OPENAI_API_KEY / ANTHROPIC_API_KEY, or configure ~/.config/lan/config.json",
            };
        }

        if (std.mem.eql(u8, err_name, "ConnectionRefused") or std.mem.eql(u8, err_name, "NetworkUnreachable") or std.mem.eql(u8, err_name, "TimedOut") or std.mem.eql(u8, err_name, "HostUnreachable")) {
            return .{
                .label = "network",
                .summary = "network connection failed",
                .next_step = "check network/proxy settings and base_url reachability, then retry",
            };
        }

        if (std.mem.eql(u8, err_name, "ProviderError")) {
            return .{
                .label = "provider",
                .summary = "provider returned a non-success response",
                .next_step = "verify provider status/model availability and API key permissions, then retry",
            };
        }

        return .{
            .label = "provider",
            .summary = "provider request failed",
            .next_step = "capture request/response logs and retry with a minimal prompt",
        };
    }

    fn renderClassifiedError(writer: anytype, info: ErrorClass) !void {
        try writer.print(Color.red ++ "[error:{s}] {s}\n" ++ Color.reset, .{ info.label, info.summary });
        try writer.print(Color.yellow ++ "next: {s}\n" ++ Color.reset, .{info.next_step});
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

            if (std.mem.eql(u8, trimmed, "\"\"\"")) {
                var multi = std.array_list.Managed(u8).init(self.allocator);
                defer multi.deinit();

                var closed = false;
                while (true) {
                    const next_line = stdin.readUntilDelimiterOrEof(&buf, '\n') catch break;
                    if (next_line == null) break;

                    const next_trimmed = std.mem.trimRight(u8, next_line.?, "\r");
                    if (std.mem.eql(u8, next_trimmed, "\"\"\"")) {
                        closed = true;
                        break;
                    }

                    if (multi.items.len > 0) try multi.append('\n');
                    try multi.appendSlice(next_trimmed);
                }

                if (!closed) {
                    try stdout.writeAll("Multiline input not closed (missing \"\"\"). Input discarded.\n");
                    continue;
                }

                if (multi.items.len == 0) {
                    try stdout.writeAll("Empty multiline input ignored.\n");
                    continue;
                }

                const response = self.agent.processInput(multi.items, stdout) catch |err| {
                    try stdout.print(Color.red ++ "Error: {s}\n" ++ Color.reset, .{@errorName(err)});
                    continue;
                };
                defer self.allocator.free(response);

                try stdout.writeAll(Color.yellow);
                try stdout.writeAll("* ");
                try stdout.writeAll(Color.reset);
                try stdout.writeAll(response);
                try stdout.writeByte('\n');
                continue;
            }

            if (std.mem.eql(u8, trimmed, "/help")) {
                self.show_help = !self.show_help;
                if (self.show_help) {
                    try printHelp(stdout);
                } else {
                    try stdout.writeAll("Help hidden.\n");
                }
                continue;
            }

            if (std.mem.eql(u8, trimmed, "/clear")) {
                self.agent.clearHistory();
                try stdout.writeAll("History cleared (system message kept).\n");
                continue;
            }

            if (!self.agent.config.hasApiKey()) {
                const info = classifyError("NoAPIKey");
                try renderClassifiedError(stdout, info);
                continue;
            }

            const response = self.agent.processInput(trimmed, stdout) catch |err| {
                const err_name = @errorName(err);
                const info = classifyError(err_name);
                try renderClassifiedError(stdout, info);
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
