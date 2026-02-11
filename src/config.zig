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

pub const ProviderRoute = struct {
    primary: Provider,
    fallback: Provider,
    timeout_ms: u32,
    retry: u8,

    pub fn deinit(_: *ProviderRoute, _: std.mem.Allocator) void {}
};

const RawProviderRoute = struct {
    primary: ?[]const u8 = null,
    fallback: ?[]const u8 = null,
    timeout_ms: ?u32 = null,
    retry: ?u8 = null,
};

pub const RouteValidationError = error{
    MissingPrimary,
    MissingFallback,
    MissingTimeout,
    MissingRetry,
    InvalidProvider,
    InvalidTimeout,
    InvalidRetry,
};

pub fn parseProviderRouteSchemaV1(allocator: std.mem.Allocator, json_text: []const u8) !ProviderRoute {
    var parsed = try std.json.parseFromSlice(RawProviderRoute, allocator, json_text, .{});
    defer parsed.deinit();

    const raw = parsed.value;
    const primary_s = raw.primary orelse return RouteValidationError.MissingPrimary;
    const fallback_s = raw.fallback orelse return RouteValidationError.MissingFallback;
    const timeout_ms = raw.timeout_ms orelse return RouteValidationError.MissingTimeout;
    const retry = raw.retry orelse return RouteValidationError.MissingRetry;

    if (timeout_ms == 0 or timeout_ms > 120_000) return RouteValidationError.InvalidTimeout;
    if (retry > 5) return RouteValidationError.InvalidRetry;

    const primary = parseProviderStrict(primary_s) orelse return RouteValidationError.InvalidProvider;
    const fallback = parseProviderStrict(fallback_s) orelse return RouteValidationError.InvalidProvider;

    return .{ .primary = primary, .fallback = fallback, .timeout_ms = timeout_ms, .retry = retry };
}

fn parseProviderStrict(str: []const u8) ?Provider {
    if (std.mem.eql(u8, str, "kimi")) return .kimi;
    if (std.mem.eql(u8, str, "anthropic")) return .anthropic;
    if (std.mem.eql(u8, str, "openai")) return .openai;
    return null;
}

pub const Config = struct {
    allocator: std.mem.Allocator,
    provider: Provider,
    route_primary: Provider,
    route_fallback: Provider,
    route_retry: u8,
    route_timeout_ms: u32,
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
            .route_primary = .kimi,
            .route_fallback = .openai,
            .route_retry = 2,
            .route_timeout_ms = 12000,
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
        if (parseStringFromJson(allocator, file_content, "\"route_primary\":\"")) |rp| {
            defer allocator.free(rp);
            config.route_primary = parseProviderStrict(rp) orelse config.route_primary;
        }
        if (parseStringFromJson(allocator, file_content, "\"route_fallback\":\"")) |rf| {
            defer allocator.free(rf);
            config.route_fallback = parseProviderStrict(rf) orelse config.route_fallback;
        }
        if (parseNumberFromJson(file_content, "\"route_retry\":")) |rr| {
            config.route_retry = @intCast(@min(rr, 5));
        }
        if (parseNumberFromJson(file_content, "\"route_timeout_ms\":")) |rt| {
            config.route_timeout_ms = @intCast(@min(@max(rt, 1), 120000));
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

    pub fn hasApiKey(self: *const Config) bool {
        return self.api_key != null and self.api_key.?.len > 0;
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
        try writer.interface.print("  \"route_primary\": \"{s}\",\n", .{self.route_primary.toString()});
        try writer.interface.print("  \"route_fallback\": \"{s}\",\n", .{self.route_fallback.toString()});
        try writer.interface.print("  \"route_retry\": {d},\n", .{self.route_retry});
        try writer.interface.print("  \"route_timeout_ms\": {d},\n", .{self.route_timeout_ms});
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

    fn parseNumberFromJson(json: []const u8, key: []const u8) ?u32 {
        const start = std.mem.indexOf(u8, json, key) orelse return null;
        const val_start = start + key.len;
        var i: usize = val_start;
        while (i < json.len and json[i] >= '0' and json[i] <= '9') : (i += 1) {}
        if (i == val_start) return null;
        return std.fmt.parseInt(u32, json[val_start..i], 10) catch null;
    }
};

test "provider route schema v1 accepts valid sample" {
    const allocator = std.testing.allocator;
    const valid =
        \\{
        \\  "primary": "kimi",
        \\  "fallback": "openai",
        \\  "timeout_ms": 12000,
        \\  "retry": 2
        \\}
    ;

    const route = try parseProviderRouteSchemaV1(allocator, valid);
    try std.testing.expect(route.primary == .kimi);
    try std.testing.expect(route.fallback == .openai);
    try std.testing.expectEqual(@as(u32, 12000), route.timeout_ms);
    try std.testing.expectEqual(@as(u8, 2), route.retry);
}

test "provider route schema v1 rejects invalid sample" {
    const allocator = std.testing.allocator;
    const invalid =
        \\{
        \\  "primary": "bad-provider",
        \\  "fallback": "openai",
        \\  "timeout_ms": 0,
        \\  "retry": 9
        \\}
    ;

    try std.testing.expectError(RouteValidationError.InvalidTimeout, parseProviderRouteSchemaV1(allocator, invalid));
}
