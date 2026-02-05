const std = @import("std");

pub const Tool = struct {
    name: []const u8,
    description: []const u8,
    parameters: []const Parameter,
    handler: *const fn (std.mem.Allocator, []const u8) anyerror![]const u8,

    pub const Parameter = struct {
        name: []const u8,
        type: []const u8,
        description: []const u8,
        required: bool,
    };
};

pub const ToolRegistry = struct {
    allocator: std.mem.Allocator,
    tools: std.StringHashMap(Tool),

    pub fn init(allocator: std.mem.Allocator) ToolRegistry {
        return ToolRegistry{
            .allocator = allocator,
            .tools = std.StringHashMap(Tool).init(allocator),
        };
    }

    pub fn deinit(self: *ToolRegistry) void {
        self.tools.deinit();
    }

    pub fn register(self: *ToolRegistry, tool: Tool) !void {
        try self.tools.put(tool.name, tool);
    }

    pub fn get(self: *ToolRegistry, name: []const u8) ?Tool {
        return self.tools.get(name);
    }

    pub fn execute(self: *ToolRegistry, name: []const u8, args: []const u8) !?[]const u8 {
        const tool = self.get(name) orelse return null;
        return try tool.handler(self.allocator, args);
    }
};

// Built-in tools
pub const BuiltinTools = struct {
    pub fn readFile(allocator: std.mem.Allocator, args: []const u8) ![]const u8 {
        // args is JSON with "path" field
        // TODO: Parse JSON properly
        const path = args; // Simplified

        const file = std.fs.cwd().openFile(path, .{}) catch |err| {
            return std.fmt.allocPrint(allocator, "Error opening file: {}", .{err});
        };
        defer file.close();

        const content = file.readToEndAlloc(allocator, 1024 * 1024) catch |err| {
            return std.fmt.allocPrint(allocator, "Error reading file: {}", .{err});
        };
        return content;
    }

    pub fn writeFile(allocator: std.mem.Allocator, args: []const u8) ![]const u8 {
        _ = args;
        // TODO: Parse JSON with path and content
        return try allocator.dupe(u8, "write_file: not fully implemented");
    }

    pub fn exec(allocator: std.mem.Allocator, args: []const u8) ![]const u8 {
        // args is the command to execute
        const cmd = args;

        const argv = &[_][]const u8{ "sh", "-c", cmd };
        var child = std.process.Child.init(argv, allocator);
        child.stdout_behavior = .Pipe;
        child.stderr_behavior = .Pipe;

        child.spawn() catch |err| {
            return std.fmt.allocPrint(allocator, "Error spawning process: {}", .{err});
        };

        var stdout = std.ArrayList(u8).init(allocator);
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
            return std.fmt.allocPrint(allocator, "Error waiting for process: {}", .{err});
        };

        if (result.Exited != 0) {
            return std.fmt.allocPrint(allocator, "Command exited with code: {d}", .{result.Exited});
        }

        return stdout.toOwnedSlice();
    }

    pub fn search(allocator: std.mem.Allocator, args: []const u8) ![]const u8 {
        _ = args;
        // TODO: Implement web search
        return try allocator.dupe(u8, "search: not implemented");
    }
};
