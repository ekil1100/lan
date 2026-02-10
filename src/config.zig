const std = @import("std");

pub const Provider = enum {
    anthropic,
    kimi,
    openai,

    pub fn fromString(str: []const u8) Provider {
        if (std.mem.eql(u8, str, "kimi")) return .kimi;
        if (std.mem.eql(u8, str, "anthropic")) return .anthropic;
        if (std.mem.eql(u8, str, "openai")) return .openai;
        return .kimi; // default
    }

    pub fn toString(self: Provider) []const u8 {
        return switch (self) {
            .kimi => "kimi",
            .anthropic => "anthropic",
            .openai => "openai",
        };
    }
};

pub const Config = struct {
    allocator: std.mem.Allocator,
    provider: Provider,
    api_key: ?[]const u8,
    model: []const u8,
    base_url: []const u8,
    config_dir: []const u8,

    // Defaults for each provider
    const kimi_model = "kimi-k2-0711-preview";
    const kimi_base_url = "https://api.moonshot.cn/v1";

    const claude_model = "claude-3-5-sonnet-20241022";
    const claude_base_url = "https://api.anthropic.com/v1";

    const openai_model = "gpt-4o";
    const openai_base_url = "https://api.openai.com/v1";

    pub fn load(allocator: std.mem.Allocator) !Config {
        // Get config directory
        const home = std.process.getEnvVarOwned(allocator, "HOME") catch |err| switch (err) {
            error.EnvironmentVariableNotFound => ".",
            else => return err,
        };
        defer if (!std.mem.eql(u8, home, ".")) allocator.free(home);

        const config_dir = try std.fs.path.join(allocator, &[_][]const u8{ home, ".config", "lan" });

        // Ensure config directory exists
        std.fs.cwd().makePath(config_dir) catch {};

        // Try to load from config file
        const config_path = try std.fs.path.join(allocator, &[_][]const u8{ config_dir, "config.json" });
        defer allocator.free(config_path);

        var config = Config{
            .allocator = allocator,
            .provider = .kimi,
            .api_key = null,
            .model = try allocator.dupe(u8, kimi_model),
            .base_url = try allocator.dupe(u8, kimi_base_url),
            .config_dir = config_dir,
        };

        // Try to read config file
        const file_content = std.fs.cwd().readFileAlloc(allocator, config_path, 4096) catch |err| switch (err) {
            error.FileNotFound => {
                // Create default config file
                try config.saveConfigFile();
                return config;
            },
            else => return err,
        };
        defer allocator.free(file_content);

        // Parse JSON (simple string matching for now)
        config.provider = parseProviderFromJson(file_content);
        if (parseStringFromJson(allocator, file_content, "\"model\":\"")) |model| {
            allocator.free(config.model);
            config.model = model;
        }
        if (parseStringFromJson(allocator, file_content, "\"base_url\":\"")) |base_url| {
            allocator.free(config.base_url);
            config.base_url = base_url;
        }

        // API key from env always takes precedence
        config.api_key = std.process.getEnvVarOwned(allocator, "MOONSHOT_API_KEY") catch null;

        if (config.api_key == null) {
            // Try to get from config file
            config.api_key = parseStringFromJson(allocator, file_content, "\"api_key\":\"");
        }

        if (config.api_key == null) {
            // Try other env vars based on provider
            config.api_key = switch (config.provider) {
                .anthropic => std.process.getEnvVarOwned(allocator, "ANTHROPIC_API_KEY") catch null,
                .openai => std.process.getEnvVarOwned(allocator, "OPENAI_API_KEY") catch null,
                .kimi => std.process.getEnvVarOwned(allocator, "MOONSHOT_API_KEY") catch null,
            };
        }

        return config;
    }

    pub fn deinit(self: *Config) void {
        if (self.api_key) |key| self.allocator.free(key);
        self.allocator.free(self.model);
        self.allocator.free(self.base_url);
        self.allocator.free(self.config_dir);
    }

    pub fn saveConfigFile(self: *Config) !void {
        const config_path = try std.fs.path.join(self.allocator, &[_][]const u8{ self.config_dir, "config.json" });
        defer self.allocator.free(config_path);

        const file = try std.fs.cwd().createFile(config_path, .{});
        defer file.close();

        var buf: [4096]u8 = undefined;
        var writer = file.writer(&buf);
        try writer.interface.print("{{\n", .{});
        try writer.interface.print("  \"provider\": \"{s}\",\n", .{self.provider.toString()});
        try writer.interface.print("  \"model\": \"{s}\",\n", .{self.model});
        try writer.interface.print("  \"base_url\": \"{s}\",\n", .{self.base_url});
        try writer.interface.print("  \"api_key\": \"{s}\"\n", .{if (self.api_key) |k| k else ""});
        try writer.interface.print("}}\n", .{});
        try writer.interface.flush();
    }

    fn parseProviderFromJson(json: []const u8) Provider {
        if (std.mem.indexOf(u8, json, "\"provider\":\"anthropic\"") != null) return .anthropic;
        if (std.mem.indexOf(u8, json, "\"provider\":\"openai\"") != null) return .openai;
        return .kimi;
    }

    fn parseStringFromJson(allocator: std.mem.Allocator, json: []const u8, key: []const u8) ?[]const u8 {
        const start = std.mem.indexOf(u8, json, key) orelse return null;
        const val_start = start + key.len;
        const end = std.mem.indexOfScalar(u8, json[val_start..], '"') orelse return null;
        return allocator.dupe(u8, json[val_start .. val_start + end]) catch return null;
    }
};
