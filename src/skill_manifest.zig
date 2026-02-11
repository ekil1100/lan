const std = @import("std");

pub const Manifest = struct {
    name: []const u8,
    version: []const u8,
    entry: []const u8,
    tools: [][]const u8,
    permissions: [][]const u8,

    pub fn deinit(self: *Manifest, allocator: std.mem.Allocator) void {
        allocator.free(self.name);
        allocator.free(self.version);
        allocator.free(self.entry);

        for (self.tools) |item| allocator.free(item);
        allocator.free(self.tools);

        for (self.permissions) |item| allocator.free(item);
        allocator.free(self.permissions);
    }
};

const RawManifest = struct {
    name: ?[]const u8 = null,
    version: ?[]const u8 = null,
    entry: ?[]const u8 = null,
    tools: ?[]const []const u8 = null,
    permissions: ?[]const []const u8 = null,
};

pub const ValidationError = error{
    MissingName,
    MissingVersion,
    MissingEntry,
    MissingTools,
    MissingPermissions,
    EmptyName,
    EmptyVersion,
    EmptyEntry,
};

pub fn parseAndValidate(allocator: std.mem.Allocator, json_text: []const u8) !Manifest {
    var parsed = try std.json.parseFromSlice(RawManifest, allocator, json_text, .{});
    defer parsed.deinit();

    const raw = parsed.value;

    const name = raw.name orelse return ValidationError.MissingName;
    const version = raw.version orelse return ValidationError.MissingVersion;
    const entry = raw.entry orelse return ValidationError.MissingEntry;
    const tools = raw.tools orelse return ValidationError.MissingTools;
    const permissions = raw.permissions orelse return ValidationError.MissingPermissions;

    if (name.len == 0) return ValidationError.EmptyName;
    if (version.len == 0) return ValidationError.EmptyVersion;
    if (entry.len == 0) return ValidationError.EmptyEntry;

    var manifest = Manifest{
        .name = try allocator.dupe(u8, name),
        .version = try allocator.dupe(u8, version),
        .entry = try allocator.dupe(u8, entry),
        .tools = try allocator.alloc([]const u8, tools.len),
        .permissions = try allocator.alloc([]const u8, permissions.len),
    };

    for (tools, 0..) |item, i| {
        manifest.tools[i] = try allocator.dupe(u8, item);
    }

    for (permissions, 0..) |item, i| {
        manifest.permissions[i] = try allocator.dupe(u8, item);
    }

    return manifest;
}

test "skill manifest schema v1 accepts valid sample" {
    const allocator = std.testing.allocator;
    const valid_sample =
        \\{
        \\  "name": "example-skill",
        \\  "version": "1.0.0",
        \\  "entry": "run.sh",
        \\  "tools": ["read", "exec"],
        \\  "permissions": ["workspace.read", "workspace.write"]
        \\}
    ;

    var manifest = try parseAndValidate(allocator, valid_sample);
    defer manifest.deinit(allocator);

    try std.testing.expectEqualStrings("example-skill", manifest.name);
    try std.testing.expectEqualStrings("1.0.0", manifest.version);
    try std.testing.expectEqualStrings("run.sh", manifest.entry);
    try std.testing.expectEqual(@as(usize, 2), manifest.tools.len);
    try std.testing.expectEqual(@as(usize, 2), manifest.permissions.len);
}

test "skill manifest schema v1 rejects invalid sample" {
    const allocator = std.testing.allocator;
    const invalid_sample =
        \\{
        \\  "name": "",
        \\  "version": "1.0.0",
        \\  "entry": "run.sh",
        \\  "tools": ["read"],
        \\  "permissions": ["workspace.read"]
        \\}
    ;

    try std.testing.expectError(ValidationError.EmptyName, parseAndValidate(allocator, invalid_sample));
}
