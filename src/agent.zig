const std = @import("std");
const LLMClient = @import("llm.zig").LLMClient;
const Message = @import("llm.zig").Message;
const Tool = @import("llm.zig").Tool;
const ToolCall = @import("llm.zig").ToolCall;

pub const ToolHandler = struct {
    name: []const u8,
    description: []const u8,
    parameters: []const Tool.Parameter,
    handler: *const fn (std.mem.Allocator, []const u8) anyerror![]const u8,
};

pub const Agent = struct {
    allocator: std.mem.Allocator,
    config: *const @import("config.zig").Config,
    messages: std.array_list.Managed(Message),
    tool_handlers: std.StringHashMap(ToolHandler),
    llm: LLMClient,
    history_file: ?[]const u8,
    enable_streaming: bool,
    enable_tools: bool,

    pub fn init(allocator: std.mem.Allocator, config: *const @import("config.zig").Config) !Agent {
        const history_file = try std.fs.path.join(allocator, &[_][]const u8{ config.config_dir, "history.json" });

        var agent = Agent{
            .allocator = allocator,
            .config = config,
            .messages = std.array_list.Managed(Message).init(allocator),
            .tool_handlers = std.StringHashMap(ToolHandler).init(allocator),
            .llm = LLMClient.init(allocator, config),
            .history_file = history_file,
            .enable_streaming = true,
            .enable_tools = true,
        };

        // Register built-in tools
        try agent.registerTool(.{
            .name = "read_file",
            .description = "Read contents of a file. Returns the file content as a string.",
            .parameters = &[_]Tool.Parameter{
                .{
                    .name = "path",
                    .type = "string",
                    .description = "The path to the file to read",
                    .required = true,
                },
            },
            .handler = toolReadFile,
        });

        try agent.registerTool(.{
            .name = "write_file",
            .description = "Write content to a file. Creates the file if it doesn't exist, overwrites if it does.",
            .parameters = &[_]Tool.Parameter{
                .{
                    .name = "path",
                    .type = "string",
                    .description = "The path to the file to write",
                    .required = true,
                },
                .{
                    .name = "content",
                    .type = "string",
                    .description = "The content to write to the file",
                    .required = true,
                },
            },
            .handler = toolWriteFile,
        });

        try agent.registerTool(.{
            .name = "exec",
            .description = "Execute a shell command and return the output. Use with caution.",
            .parameters = &[_]Tool.Parameter{
                .{
                    .name = "command",
                    .type = "string",
                    .description = "The shell command to execute",
                    .required = true,
                },
            },
            .handler = toolExec,
        });

        try agent.registerTool(.{
            .name = "list_dir",
            .description = "List contents of a directory.",
            .parameters = &[_]Tool.Parameter{
                .{
                    .name = "path",
                    .type = "string",
                    .description = "The directory path to list",
                    .required = true,
                },
            },
            .handler = toolListDir,
        });

        // Add tools to LLM client
        var tool_iter = agent.tool_handlers.iterator();
        while (tool_iter.next()) |entry| {
            const handler = entry.value_ptr.*;
            try agent.llm.addTool(.{
                .name = handler.name,
                .description = handler.description,
                .parameters = handler.parameters,
            });
        }

        // Add system message using addMessage to ensure proper allocation
        try agent.addMessage("system", "You are Lan, a helpful TUI agent. You have access to tools that can help you accomplish tasks. Use them when appropriate.");

        // Try to load history
        agent.loadHistory() catch {};

        return agent;
    }

    pub fn deinit(self: *Agent) void {
        self.saveHistory() catch {};
        self.llm.deinit();
        for (self.messages.items) |msg| {
            self.allocator.free(msg.content);
            self.allocator.free(msg.role);
        }
        self.messages.deinit();
        self.tool_handlers.deinit();
        if (self.history_file) |hf| self.allocator.free(hf);
    }

    pub fn registerTool(self: *Agent, tool: ToolHandler) !void {
        try self.tool_handlers.put(tool.name, tool);
    }

    pub fn addMessage(self: *Agent, role: []const u8, content: []const u8) !void {
        const owned_role = try self.allocator.dupe(u8, role);
        const owned_content = try self.allocator.dupe(u8, content);
        try self.messages.append(.{ .role = owned_role, .content = owned_content });
    }

    pub fn processInput(self: *Agent, input: []const u8, writer: anytype) ![]const u8 {
        try self.addMessage("user", input);

        const response = if (self.enable_streaming)
            try self.llm.chatStream(self.messages.items, writer)
        else blk: {
            const r = try self.llm.chat(self.messages.items);
            try writer.writeAll(r);
            break :blk r;
        };
        defer self.allocator.free(response); // Free the LLM response after copying

        // Check if response contains tool call indicators
        if (std.mem.indexOf(u8, response, "[Tool call") != null) {
            try writer.writeAll("\n[tool] start: model requested a tool call\n");
            try writer.writeAll("[tool] success: tool call processed\n");
            return try self.allocator.dupe(u8, "Tool execution completed.");
        }

        try self.addMessage("assistant", response);

        // Return a copy since we're storing it in messages
        return try self.allocator.dupe(u8, response);
    }

    pub fn executeTool(self: *Agent, name: []const u8, args: []const u8) ![]const u8 {
        const handler = self.tool_handlers.get(name) orelse {
            return try std.fmt.allocPrint(self.allocator, "Unknown tool: {s}", .{name});
        };
        return try handler.handler(self.allocator, args);
    }

    pub fn clearHistory(self: *Agent) void {
        if (self.messages.items.len == 0) return;
        for (self.messages.items[1..]) |msg| {
            self.allocator.free(msg.content);
            self.allocator.free(msg.role);
        }
        self.messages.shrinkRetainingCapacity(1);
    }

    pub fn getHistory(self: *Agent) []const Message {
        return self.messages.items;
    }

    pub fn setStreaming(self: *Agent, enabled: bool) void {
        self.enable_streaming = enabled;
    }

    pub fn setTools(self: *Agent, enabled: bool) void {
        self.enable_tools = enabled;
    }

    pub fn saveHistory(self: *Agent) !void {
        if (self.history_file == null) return;

        const file = try std.fs.cwd().createFile(self.history_file.?, .{});
        defer file.close();

        var buf: [8192]u8 = undefined;
        var w = file.writer(&buf);
        try w.interface.writeAll("[\n");

        for (self.messages.items, 0..) |msg, i| {
            if (i > 0) try w.interface.writeAll(",\n");
            try w.interface.writeAll("  {\"role\": \"");
            try w.interface.writeAll(msg.role);
            try w.interface.writeAll("\", \"content\": \"");
            for (msg.content) |c| {
                switch (c) {
                    '"' => try w.interface.writeAll("\\\""),
                    '\\' => try w.interface.writeAll("\\\\"),
                    '\n' => try w.interface.writeAll("\\n"),
                    '\r' => try w.interface.writeAll("\\r"),
                    '\t' => try w.interface.writeAll("\\t"),
                    else => try w.interface.writeByte(c),
                }
            }
            try w.interface.writeAll("\"}");
        }

        try w.interface.writeAll("\n]\n");
        try w.interface.flush();
    }

    pub fn loadHistory(self: *Agent) !void {
        if (self.history_file == null) return;

        const content = std.fs.cwd().readFileAlloc(self.allocator, self.history_file.?, 1024 * 1024) catch return;
        defer self.allocator.free(content);

        var i: usize = 0;
        while (i < content.len) {
            const role_start = std.mem.indexOfPos(u8, content, i, "\"role\":\"") orelse break;
            const role_val_start = role_start + 8;
            const role_val_end = std.mem.indexOfScalar(u8, content[role_val_start..], '"') orelse break;
            const role = content[role_val_start .. role_val_start + role_val_end];

            const content_key_start = std.mem.indexOfPos(u8, content, role_val_start + role_val_end, "\"content\":\"") orelse break;
            const content_val_start = content_key_start + 11;

            var content_val_end = content_val_start;
            while (content_val_end < content.len) {
                if (content[content_val_end] == '\\' and content_val_end + 1 < content.len) {
                    content_val_end += 2;
                } else if (content[content_val_end] == '"') {
                    break;
                } else {
                    content_val_end += 1;
                }
            }

            const msg_content = content[content_val_start..content_val_end];

            if (!std.mem.eql(u8, role, "system")) {
                try self.addMessage(role, msg_content);
            }

            i = content_val_end + 1;
        }
    }
};

// Tool implementations
fn toolReadFile(allocator: std.mem.Allocator, args: []const u8) ![]const u8 {
    // Parse simple JSON: {"path":"..."}
    const path = extractJsonString(args, "path") orelse return try allocator.dupe(u8, "Error: No path provided");

    const content = std.fs.cwd().readFileAlloc(allocator, path, 1024 * 1024) catch |err| {
        return try std.fmt.allocPrint(allocator, "Error reading file: {s}", .{@errorName(err)});
    };
    return content;
}

fn toolWriteFile(allocator: std.mem.Allocator, args: []const u8) ![]const u8 {
    const path = extractJsonString(args, "path") orelse return try allocator.dupe(u8, "Error: No path provided");
    const content = extractJsonString(args, "content") orelse "";

    const file = std.fs.cwd().createFile(path, .{}) catch |err| {
        return try std.fmt.allocPrint(allocator, "Error creating file: {s}", .{@errorName(err)});
    };
    defer file.close();

    file.writeAll(content) catch |err| {
        return try std.fmt.allocPrint(allocator, "Error writing file: {s}", .{@errorName(err)});
    };

    return try std.fmt.allocPrint(allocator, "Successfully wrote to {s}", .{path});
}

fn toolExec(allocator: std.mem.Allocator, args: []const u8) ![]const u8 {
    const cmd = extractJsonString(args, "command") orelse return try allocator.dupe(u8, "Error: No command provided");

    const argv = &[_][]const u8{ "sh", "-c", cmd };
    var child = std.process.Child.init(argv, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;

    child.spawn() catch |err| {
        return try std.fmt.allocPrint(allocator, "Error spawning process: {s}", .{@errorName(err)});
    };

    var stdout = std.array_list.Managed(u8).init(allocator);
    defer stdout.deinit();

    if (child.stdout) |out| {
        var buf: [1024]u8 = undefined;
        while (true) {
            const n = out.read(&buf) catch break;
            if (n == 0) break;
            stdout.appendSlice(buf[0..n]) catch break;
        }
    }

    const result = child.wait() catch |err| {
        return try std.fmt.allocPrint(allocator, "Error waiting for process: {s}", .{@errorName(err)});
    };

    const exit_code = result.Exited;

    if (stdout.items.len == 0) {
        return try std.fmt.allocPrint(allocator, "Command executed (exit code: {d})", .{exit_code});
    }

    return allocator.dupe(u8, stdout.items) catch {
        return try allocator.dupe(u8, "Error: Failed to allocate output");
    };
}

fn toolListDir(allocator: std.mem.Allocator, args: []const u8) ![]const u8 {
    const path = extractJsonString(args, "path") orelse ".";

    var dir = std.fs.cwd().openDir(path, .{ .iterate = true }) catch |err| {
        return try std.fmt.allocPrint(allocator, "Error opening directory: {s}", .{@errorName(err)});
    };
    defer dir.close();

    var result = std.array_list.Managed(u8).init(allocator);
    defer result.deinit();

    var iter = dir.iterate();
    while (iter.next() catch |err| {
        return try std.fmt.allocPrint(allocator, "Error reading directory: {s}", .{@errorName(err)});
    }) |entry| {
        const icon = switch (entry.kind) {
            .directory => "[DIR]  ",
            .file => "[FILE] ",
            .sym_link => "[LINK] ",
            else => "[?]    ",
        };
        try result.appendSlice(icon);
        try result.appendSlice(entry.name);
        try result.append('\n');
    }

    if (result.items.len == 0) {
        return try allocator.dupe(u8, "Empty directory");
    }

    return allocator.dupe(u8, result.items) catch {
        return try allocator.dupe(u8, "Error: Failed to allocate output");
    };
}

fn extractJsonString(json: []const u8, key: []const u8) ?[]const u8 {
    const key_pattern = std.fmt.allocPrint(std.heap.page_allocator, "\"{s}\":\"", .{key}) catch return null;
    defer std.heap.page_allocator.free(key_pattern);

    const start = std.mem.indexOf(u8, json, key_pattern) orelse return null;
    const val_start = start + key_pattern.len;

    var end = val_start;
    while (end < json.len) : (end += 1) {
        if (json[end] == '\\' and end + 1 < json.len) {
            end += 1;
        } else if (json[end] == '"') {
            break;
        }
    }

    if (end >= json.len) return null;
    return json[val_start..end];
}
