const std = @import("std");
const Config = @import("config.zig").Config;
const Provider = @import("config.zig").Provider;

pub const Message = struct {
    role: []const u8,
    content: []const u8,
};

pub const Tool = struct {
    name: []const u8,
    description: []const u8,
    parameters: []const Parameter,

    pub const Parameter = struct {
        name: []const u8,
        type: []const u8,
        description: []const u8,
        required: bool,
    };
};

pub const ToolCall = struct {
    name: []const u8,
    arguments: []const u8,
};

pub const StreamChunk = struct {
    content: []const u8,
    is_done: bool,
    tool_calls: ?[]const ToolCall,
};

pub const LLMClient = struct {
    allocator: std.mem.Allocator,
    config: *const Config,
    http_client: std.http.Client,
    tools: std.array_list.Managed(Tool),

    pub fn init(allocator: std.mem.Allocator, config: *const Config) LLMClient {
        return LLMClient{
            .allocator = allocator,
            .config = config,
            .http_client = std.http.Client{ .allocator = allocator },
            .tools = std.array_list.Managed(Tool).init(allocator),
        };
    }

    pub fn deinit(self: *LLMClient) void {
        self.http_client.deinit();
        self.tools.deinit();
    }

    pub fn addTool(self: *LLMClient, tool: Tool) !void {
        try self.tools.append(tool);
    }

    pub fn chat(self: *LLMClient, messages: []const Message) ![]const u8 {
        if (self.config.api_key == null) {
            return error.NoAPIKey;
        }

        var attempts: u32 = 0;
        const max_attempts = 3;

        while (attempts < max_attempts) : (attempts += 1) {
            const result = switch (self.config.provider) {
                .kimi, .openai => self.chatOpenAI(messages),
                .anthropic => self.chatAnthropic(messages),
            };

            return result catch |err| {
                if (attempts == max_attempts - 1) return err;
                std.Thread.sleep(1 * std.time.ns_per_s);
                continue;
            };
        }

        return error.MaxRetriesExceeded;
    }

    pub fn chatStream(
        self: *LLMClient,
        messages: []const Message,
        writer: anytype,
    ) ![]const u8 {
        if (self.config.api_key == null) {
            return error.NoAPIKey;
        }

        return switch (self.config.provider) {
            .kimi, .openai => try self.chatOpenAIStream(messages, writer),
            .anthropic => try self.chatAnthropicStream(messages, writer),
        };
    }

    fn chatOpenAI(self: *LLMClient, messages: []const Message) ![]const u8 {
        const uri_str = try std.fmt.allocPrint(self.allocator, "{s}/chat/completions", .{self.config.base_url});
        defer self.allocator.free(uri_str);
        const uri = try std.Uri.parse(uri_str);

        var body = std.array_list.Managed(u8).init(self.allocator);
        defer body.deinit();

        var writer = body.writer();

        try writer.writeAll("{\"model\":\"");
        try writer.writeAll(self.config.model);
        try writer.writeAll("\",\"messages\":[");

        for (messages, 0..) |msg, i| {
            if (i > 0) try writer.writeByte(',');
            try writer.writeAll("{\"role\":\"");
            try writer.writeAll(msg.role);
            try writer.writeAll("\",\"content\":\"");
            try escapeJsonString(&writer, msg.content);
            try writer.writeByte('"');
            try writer.writeByte('}');
        }

        try writer.writeAll("],");

        // Add tools if available
        if (self.tools.items.len > 0) {
            try writer.writeAll("\"tools\":[");
            for (self.tools.items, 0..) |tool, i| {
                if (i > 0) try writer.writeByte(',');
                try writer.writeAll("{\"type\":\"function\",\"function\":{\"name\":\"");
                try writer.writeAll(tool.name);
                try writer.writeAll("\",\"description\":\"");
                try escapeJsonString(&writer, tool.description);
                try writer.writeAll("\",\"parameters\":{\"type\":\"object\",\"properties\":{");

                for (tool.parameters, 0..) |param, j| {
                    if (j > 0) try writer.writeByte(',');
                    try writer.writeAll("\"");
                    try writer.writeAll(param.name);
                    try writer.writeAll("\":{\"type\":\"");
                    try writer.writeAll(param.type);
                    try writer.writeAll("\",\"description\":\"");
                    try escapeJsonString(&writer, param.description);
                    try writer.writeAll("\"}");
                }

                try writer.writeAll("}");
                if (tool.parameters.len > 0) {
                    try writer.writeAll(",\"required\":[");
                    var first_required = true;
                    for (tool.parameters) |param| {
                        if (param.required) {
                            if (!first_required) try writer.writeByte(',');
                            try writer.writeAll("\"");
                            try writer.writeAll(param.name);
                            try writer.writeAll("\"");
                            first_required = false;
                        }
                    }
                    try writer.writeAll("]");
                }
                try writer.writeAll("}}");
            }
            try writer.writeAll("],");
            try writer.writeAll("\"tool_choice\":\"auto\",");
        }

        try writer.writeAll("\"temperature\":0.7,");
        try writer.writeAll("\"stream\":false");
        try writer.writeAll("}");

        const auth_header = try std.fmt.allocPrint(self.allocator, "Bearer {s}", .{self.config.api_key.?});
        defer self.allocator.free(auth_header);

        var req = try self.http_client.request(.POST, uri, .{
            .headers = .{
                .authorization = .{ .override = auth_header },
                .content_type = .{ .override = "application/json" },
            },
        });
        defer req.deinit();

        req.transfer_encoding = .{ .content_length = body.items.len };
        var req_body = try req.sendBody(&.{});
        try req_body.writer.writeAll(body.items);
        try req_body.end();

        var response_head = try req.receiveHead(&.{});
        if (response_head.head.status.class() != .success) {
            return error.ProviderError;
        }
        var transfer_buffer: [4096]u8 = undefined;
        var response_reader = response_head.reader(&transfer_buffer);
        const response = try response_reader.allocRemaining(self.allocator, .limited(1024 * 1024));
        defer self.allocator.free(response);

        // Check for tool calls
        if (std.mem.indexOf(u8, response, "\"tool_calls\"") != null) {
            // Parse tool calls
            return try parseToolCallsResponse(self.allocator, response);
        }

        return try parseOpenAIResponse(self.allocator, response);
    }

    fn chatOpenAIStream(
        self: *LLMClient,
        messages: []const Message,
        output_writer: anytype,
    ) ![]const u8 {
        const uri_str = try std.fmt.allocPrint(self.allocator, "{s}/chat/completions", .{self.config.base_url});
        defer self.allocator.free(uri_str);
        const uri = try std.Uri.parse(uri_str);

        var body = std.array_list.Managed(u8).init(self.allocator);
        defer body.deinit();

        var writer = body.writer();

        try writer.writeAll("{\"model\":\"");
        try writer.writeAll(self.config.model);
        try writer.writeAll("\",\"messages\":[");

        for (messages, 0..) |msg, i| {
            if (i > 0) try writer.writeByte(',');
            try writer.writeAll("{\"role\":\"");
            try writer.writeAll(msg.role);
            try writer.writeAll("\",\"content\":\"");
            try escapeJsonString(&writer, msg.content);
            try writer.writeByte('"');
            try writer.writeByte('}');
        }

        try writer.writeAll("],\"temperature\":0.7,\"stream\":true}");

        const auth_header = try std.fmt.allocPrint(self.allocator, "Bearer {s}", .{self.config.api_key.?});
        defer self.allocator.free(auth_header);

        var req = try self.http_client.request(.POST, uri, .{
            .headers = .{
                .authorization = .{ .override = auth_header },
                .content_type = .{ .override = "application/json" },
            },
        });
        defer req.deinit();

        req.transfer_encoding = .{ .content_length = body.items.len };
        var req_body = try req.sendBody(&.{});
        try req_body.writer.writeAll(body.items);
        try req_body.end();

        var response_head = try req.receiveHead(&.{});
        if (response_head.head.status.class() != .success) {
            return error.ProviderError;
        }
        var transfer_buffer: [4096]u8 = undefined;
        var response_reader = response_head.reader(&transfer_buffer);

        var accumulated = std.array_list.Managed(u8).init(self.allocator);
        defer accumulated.deinit();

        var pending = std.array_list.Managed(u8).init(self.allocator);
        defer pending.deinit();

        var read_buf: [2048]u8 = undefined;
        var done = false;

        while (!done) {
            const n = try response_reader.readSliceShort(&read_buf);
            if (n == 0) break;

            try pending.appendSlice(read_buf[0..n]);

            var start: usize = 0;
            while (start < pending.items.len) {
                const rel_nl = std.mem.indexOfScalar(u8, pending.items[start..], '\n') orelse break;
                const end = start + rel_nl;
                const raw_line = std.mem.trimRight(u8, pending.items[start..end], "\r");
                start = end + 1;

                switch (parseSseDataLine(raw_line)) {
                    .done => {
                        done = true;
                        break;
                    },
                    .none => {},
                    .content => |raw_content| {
                        const content = try unescapeJsonString(self.allocator, raw_content);
                        defer self.allocator.free(content);

                        if (content.len > 0) {
                            try output_writer.writeAll(content);
                            try accumulated.appendSlice(content);
                        }
                    },
                }
            }

            if (start > 0) {
                std.mem.copyForwards(u8, pending.items[0 .. pending.items.len - start], pending.items[start..]);
                pending.items.len -= start;
            }
        }

        return try accumulated.toOwnedSlice();
    }

    fn chatAnthropic(self: *LLMClient, messages: []const Message) ![]const u8 {
        const uri_str = try std.fmt.allocPrint(self.allocator, "{s}/messages", .{self.config.base_url});
        defer self.allocator.free(uri_str);
        const uri = try std.Uri.parse(uri_str);

        var body = std.array_list.Managed(u8).init(self.allocator);
        defer body.deinit();

        var writer = body.writer();

        try writer.writeAll("{\"model\":\"");
        try writer.writeAll(self.config.model);
        try writer.writeAll("\",\"max_tokens\":4096,\"messages\":[");

        for (messages, 0..) |msg, i| {
            if (i > 0) try writer.writeByte(',');
            try writer.writeAll("{\"role\":\"");
            try writer.writeAll(msg.role);
            try writer.writeAll("\",\"content\":\"");
            try escapeJsonString(&writer, msg.content);
            try writer.writeByte('"');
            try writer.writeByte('}');
        }

        try writer.writeAll("]}");

        const auth_header = try std.fmt.allocPrint(self.allocator, "Bearer {s}", .{self.config.api_key.?});
        defer self.allocator.free(auth_header);

        const extra_headers = [_]std.http.Header{
            .{ .name = "anthropic-version", .value = "2023-06-01" },
        };

        var req = try self.http_client.request(.POST, uri, .{
            .headers = .{
                .authorization = .{ .override = auth_header },
                .content_type = .{ .override = "application/json" },
            },
            .extra_headers = &extra_headers,
        });
        defer req.deinit();

        req.transfer_encoding = .{ .content_length = body.items.len };
        var req_body = try req.sendBody(&.{});
        try req_body.writer.writeAll(body.items);
        try req_body.end();

        var response_head = try req.receiveHead(&.{});
        if (response_head.head.status.class() != .success) {
            return error.ProviderError;
        }
        var transfer_buffer: [4096]u8 = undefined;
        var response_reader = response_head.reader(&transfer_buffer);
        const response = try response_reader.allocRemaining(self.allocator, .limited(1024 * 1024));
        defer self.allocator.free(response);

        return try parseAnthropicResponse(self.allocator, response);
    }

    fn chatAnthropicStream(
        self: *LLMClient,
        messages: []const Message,
        output_writer: anytype,
    ) ![]const u8 {
        // For now, fall back to non-streaming for Anthropic
        const response = try self.chatAnthropic(messages);
        try output_writer.writeAll(response);
        return response;
    }

    fn parseOpenAIResponse(allocator: std.mem.Allocator, response: []const u8) ![]const u8 {
        const content_key = "\"content\":\"";
        const start = std.mem.indexOf(u8, response, content_key) orelse {
            return try allocator.dupe(u8, "Error: Could not parse response (no content field)");
        };

        const content_start = start + content_key.len;

        var content_end = content_start;
        while (content_end < response.len) : (content_end += 1) {
            if (response[content_end] == '\\' and content_end + 1 < response.len) {
                content_end += 1;
            } else if (response[content_end] == '"') {
                break;
            }
        }

        if (content_end >= response.len) {
            return try allocator.dupe(u8, "Error: Unterminated content string");
        }

        const raw_content = response[content_start..content_end];
        return try unescapeJsonString(allocator, raw_content);
    }

    fn parseAnthropicResponse(allocator: std.mem.Allocator, response: []const u8) ![]const u8 {
        return try parseOpenAIResponse(allocator, response);
    }

    fn parseToolCallsResponse(allocator: std.mem.Allocator, _: []const u8) ![]const u8 {
        // Return the tool_calls info as a string for now
        return try allocator.dupe(u8, "[Tool call detected - processing...]");
    }

    const SseLine = union(enum) {
        none,
        done,
        content: []const u8,
    };

    fn parseSseDataLine(raw_line: []const u8) SseLine {
        if (!std.mem.startsWith(u8, raw_line, "data: ")) return .none;

        const payload = raw_line[6..];
        if (std.mem.eql(u8, payload, "[DONE]")) return .done;

        if (extractSsePayloadContent(payload)) |raw_content| {
            return .{ .content = raw_content };
        }

        return .none;
    }

    fn extractSsePayloadContent(payload: []const u8) ?[]const u8 {
        const delta_key = "\"delta\":{\"content\":\"";
        const start = std.mem.indexOf(u8, payload, delta_key) orelse return null;
        const content_start = start + delta_key.len;

        var content_end = content_start;
        while (content_end < payload.len) : (content_end += 1) {
            if (payload[content_end] == '\\' and content_end + 1 < payload.len) {
                content_end += 1;
            } else if (payload[content_end] == '"') {
                break;
            }
        }

        if (content_end >= payload.len) return null;
        return payload[content_start..content_end];
    }
};

fn escapeJsonString(writer: *std.array_list.Managed(u8).Writer, str: []const u8) !void {
    for (str) |c| {
        switch (c) {
            '"' => try writer.writeAll("\\\""),
            '\\' => try writer.writeAll("\\\\"),
            '\n' => try writer.writeAll("\\n"),
            '\r' => try writer.writeAll("\\r"),
            '\t' => try writer.writeAll("\\t"),
            else => try writer.writeByte(c),
        }
    }
}

fn unescapeJsonString(allocator: std.mem.Allocator, str: []const u8) ![]const u8 {
    var result = std.array_list.Managed(u8).init(allocator);
    defer result.deinit();

    var i: usize = 0;
    while (i < str.len) : (i += 1) {
        if (str[i] == '\\' and i + 1 < str.len) {
            i += 1;
            switch (str[i]) {
                '"' => try result.append('"'),
                '\\' => try result.append('\\'),
                'n' => try result.append('\n'),
                'r' => try result.append('\r'),
                't' => try result.append('\t'),
                else => try result.append(str[i]),
            }
        } else {
            try result.append(str[i]);
        }
    }

    return result.toOwnedSlice();
}

test "SSE parser handles multi-chunk content and DONE" {
    const allocator = std.testing.allocator;

    const chunks = [_][]const u8{
        "data: {\"choices\":[{\"delta\":{\"content\":\"Hel",
        "lo\"}}]}\n",
        "data: {\"choices\":[{\"delta\":{\"content\":\" world\"}}]}\n",
        "data: [DONE]\n",
    };

    var pending = std.array_list.Managed(u8).init(allocator);
    defer pending.deinit();

    var out = std.array_list.Managed(u8).init(allocator);
    defer out.deinit();

    var done = false;
    for (chunks) |chunk| {
        try pending.appendSlice(chunk);

        var start: usize = 0;
        while (start < pending.items.len) {
            const rel_nl = std.mem.indexOfScalar(u8, pending.items[start..], '\n') orelse break;
            const end = start + rel_nl;
            const raw_line = std.mem.trimRight(u8, pending.items[start..end], "\r");
            start = end + 1;

            switch (LLMClient.parseSseDataLine(raw_line)) {
                .done => {
                    done = true;
                    break;
                },
                .none => {},
                .content => |raw| {
                    const s = try unescapeJsonString(allocator, raw);
                    defer allocator.free(s);
                    try out.appendSlice(s);
                },
            }
        }

        if (start > 0) {
            std.mem.copyForwards(u8, pending.items[0 .. pending.items.len - start], pending.items[start..]);
            pending.items.len -= start;
        }

        if (done) break;
    }

    try std.testing.expect(done);
    try std.testing.expectEqualStrings("Hello world", out.items);
}

test "SSE parser handles partial-line buffering across chunks" {
    const allocator = std.testing.allocator;

    const chunks = [_][]const u8{
        "data: {\"choices\":[{\"delta\":{\"content\":\"par",
        "tial\"}}]}",
        "\n",
        "data: [DONE]\n",
    };

    var pending = std.array_list.Managed(u8).init(allocator);
    defer pending.deinit();

    var out = std.array_list.Managed(u8).init(allocator);
    defer out.deinit();

    var done = false;
    for (chunks) |chunk| {
        try pending.appendSlice(chunk);

        var start: usize = 0;
        while (start < pending.items.len) {
            const rel_nl = std.mem.indexOfScalar(u8, pending.items[start..], '\n') orelse break;
            const end = start + rel_nl;
            const raw_line = std.mem.trimRight(u8, pending.items[start..end], "\r");
            start = end + 1;

            switch (LLMClient.parseSseDataLine(raw_line)) {
                .done => {
                    done = true;
                    break;
                },
                .none => {},
                .content => |raw| {
                    const s = try unescapeJsonString(allocator, raw);
                    defer allocator.free(s);
                    try out.appendSlice(s);
                },
            }
        }

        if (start > 0) {
            std.mem.copyForwards(u8, pending.items[0 .. pending.items.len - start], pending.items[start..]);
            pending.items.len -= start;
        }

        if (done) break;
    }

    try std.testing.expect(done);
    try std.testing.expectEqualStrings("partial", out.items);
}

test "SSE parser unescapes newline and quote content" {
    const allocator = std.testing.allocator;

    const line = "data: {\"choices\":[{\"delta\":{\"content\":\"line1\\n\\\"q\\\"\"}}]}";
    switch (LLMClient.parseSseDataLine(line)) {
        .content => |raw| {
            const s = try unescapeJsonString(allocator, raw);
            defer allocator.free(s);
            try std.testing.expectEqualStrings("line1\n\"q\"", s);
        },
        else => return error.TestUnexpectedResult,
    }
}

test "SSE parser tolerates malformed lines" {
    switch (LLMClient.parseSseDataLine("event: ping")) {
        .none => {},
        else => return error.TestUnexpectedResult,
    }

    switch (LLMClient.parseSseDataLine("data: {not-json}")) {
        .none => {},
        else => return error.TestUnexpectedResult,
    }

    switch (LLMClient.parseSseDataLine("data: [DONE]")) {
        .done => {},
        else => return error.TestUnexpectedResult,
    }
}
