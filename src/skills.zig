const std = @import("std");
const skill_manifest = @import("skill_manifest.zig");

const IndexEntry = struct {
    name: []const u8,
    version: []const u8,
    path: []const u8,
    permissions: []const u8,
};

const IndexFile = struct {
    skills: []IndexEntry,
};

pub fn listSkills(allocator: std.mem.Allocator, config_dir: []const u8) ![]const u8 {
    const skills_root = try std.fs.path.join(allocator, &[_][]const u8{ config_dir, "skills" });
    defer allocator.free(skills_root);
    return listSkillsFromRoot(allocator, skills_root);
}

pub fn addSkill(allocator: std.mem.Allocator, config_dir: []const u8, source_dir: []const u8) ![]const u8 {
    const skills_root = try std.fs.path.join(allocator, &[_][]const u8{ config_dir, "skills" });
    defer allocator.free(skills_root);
    return addSkillFromRoot(allocator, skills_root, source_dir);
}

pub fn updateSkill(allocator: std.mem.Allocator, config_dir: []const u8, source_dir: []const u8) ![]const u8 {
    const skills_root = try std.fs.path.join(allocator, &[_][]const u8{ config_dir, "skills" });
    defer allocator.free(skills_root);
    return updateSkillFromRoot(allocator, skills_root, source_dir);
}

pub fn removeSkill(allocator: std.mem.Allocator, config_dir: []const u8, skill_name: []const u8) ![]const u8 {
    const skills_root = try std.fs.path.join(allocator, &[_][]const u8{ config_dir, "skills" });
    defer allocator.free(skills_root);
    return removeSkillFromRoot(allocator, skills_root, skill_name);
}

pub fn removeSkillFromRoot(allocator: std.mem.Allocator, skills_root: []const u8, skill_name: []const u8) ![]const u8 {
    if (skill_name.len == 0 or std.mem.indexOf(u8, skill_name, "/") != null or std.mem.eql(u8, skill_name, ".") or std.mem.eql(u8, skill_name, "..")) {
        return std.fmt.allocPrint(
            allocator,
            "Skill remove failed: invalid name ({s})\nnext: use a plain skill name (e.g. demo-skill) and retry `lan skill remove <name>`.\n",
            .{skill_name},
        );
    }

    const skill_dir = try std.fs.path.join(allocator, &[_][]const u8{ skills_root, skill_name });
    defer allocator.free(skill_dir);

    var existing_dir = std.fs.cwd().openDir(skill_dir, .{}) catch {
        return std.fmt.allocPrint(
            allocator,
            "Skill remove failed: not found ({s})\nnext: run `lan skill list` to check installed names, then retry `lan skill remove <name>`.\n",
            .{skill_name},
        );
    };
    existing_dir.close();

    std.fs.cwd().deleteTree(skill_dir) catch |err| switch (err) {
        error.AccessDenied, error.PermissionDenied => {
            return std.fmt.allocPrint(
                allocator,
                "Skill remove failed: permission denied ({s})\nnext: check directory permissions under ~/.config/lan/skills and retry.\n",
                .{skill_name},
            );
        },
        else => return err,
    };

    try refreshIndexFromRoot(allocator, skills_root);
    return std.fmt.allocPrint(allocator, "Skill removed: name={s}\n", .{skill_name});
}

fn loadSourceManifest(allocator: std.mem.Allocator, source_dir: []const u8, action: []const u8) !struct { text: []const u8, manifest: skill_manifest.Manifest } {
    const src_manifest = try std.fs.path.join(allocator, &[_][]const u8{ source_dir, "manifest.json" });
    defer allocator.free(src_manifest);

    const src_text = std.fs.cwd().readFileAlloc(allocator, src_manifest, 64 * 1024) catch {
        return error.FileNotFound;
    };

    const manifest = skill_manifest.parseAndValidate(allocator, src_text) catch {
        allocator.free(src_text);
        return error.InvalidData;
    };

    _ = action;
    return .{ .text = src_text, .manifest = manifest };
}

pub fn addSkillFromRoot(allocator: std.mem.Allocator, skills_root: []const u8, source_dir: []const u8) ![]const u8 {
    var loaded = loadSourceManifest(allocator, source_dir, "add") catch |err| switch (err) {
        error.FileNotFound => {
            return allocator.dupe(
                u8,
                "Skill install failed: missing manifest.json\nnext: provide a local folder containing manifest.json and retry `lan skill add <path>`.\n",
            );
        },
        error.InvalidData => {
            return allocator.dupe(
                u8,
                "Skill install failed: invalid manifest schema\nnext: ensure name/version/entry/tools/permissions are valid, then retry.\n",
            );
        },
        else => return err,
    };
    defer allocator.free(loaded.text);
    defer loaded.manifest.deinit(allocator);

    try std.fs.cwd().makePath(skills_root);

    const dst_dir = try std.fs.path.join(allocator, &[_][]const u8{ skills_root, loaded.manifest.name });
    defer allocator.free(dst_dir);
    try std.fs.cwd().makePath(dst_dir);

    const dst_manifest = try std.fs.path.join(allocator, &[_][]const u8{ dst_dir, "manifest.json" });
    defer allocator.free(dst_manifest);
    try std.fs.cwd().writeFile(.{ .sub_path = dst_manifest, .data = loaded.text });

    const perms = try joinPermissions(allocator, loaded.manifest.permissions);
    defer allocator.free(perms);

    try refreshIndexFromRoot(allocator, skills_root);
    return std.fmt.allocPrint(allocator, "Skill installed: name={s} version={s} perms={s} path={s}\n", .{ loaded.manifest.name, loaded.manifest.version, perms, dst_manifest });
}

pub fn updateSkillFromRoot(allocator: std.mem.Allocator, skills_root: []const u8, source_dir: []const u8) ![]const u8 {
    var loaded = loadSourceManifest(allocator, source_dir, "update") catch |err| switch (err) {
        error.FileNotFound => {
            return allocator.dupe(
                u8,
                "Skill update failed: missing manifest.json\nnext: provide a local folder containing manifest.json and retry `lan skill update <path>`.\n",
            );
        },
        error.InvalidData => {
            return allocator.dupe(
                u8,
                "Skill update failed: invalid manifest schema\nnext: ensure name/version/entry/tools/permissions are valid, then retry.\n",
            );
        },
        else => return err,
    };
    defer allocator.free(loaded.text);
    defer loaded.manifest.deinit(allocator);

    const target_dir = try std.fs.path.join(allocator, &[_][]const u8{ skills_root, loaded.manifest.name });
    defer allocator.free(target_dir);

    var existing = std.fs.cwd().openDir(target_dir, .{}) catch {
        return std.fmt.allocPrint(
            allocator,
            "Skill update failed: target not installed ({s})\nnext: run `lan skill list` then `lan skill add <path>` for first install.\n",
            .{loaded.manifest.name},
        );
    };
    existing.close();

    const dst_manifest = try std.fs.path.join(allocator, &[_][]const u8{ target_dir, "manifest.json" });
    defer allocator.free(dst_manifest);
    try std.fs.cwd().writeFile(.{ .sub_path = dst_manifest, .data = loaded.text });

    const perms = try joinPermissions(allocator, loaded.manifest.permissions);
    defer allocator.free(perms);

    try refreshIndexFromRoot(allocator, skills_root);
    return std.fmt.allocPrint(allocator, "Skill updated: name={s} version={s} perms={s} path={s}\n", .{ loaded.manifest.name, loaded.manifest.version, perms, dst_manifest });
}

fn lessString(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.order(u8, a, b) == .lt;
}

fn joinPermissions(allocator: std.mem.Allocator, permissions: [][]const u8) ![]u8 {
    if (permissions.len == 0) return allocator.dupe(u8, "[]");

    const sorted = try allocator.alloc([]const u8, permissions.len);
    defer allocator.free(sorted);
    for (permissions, 0..) |p, i| sorted[i] = p;
    std.sort.heap([]const u8, sorted, {}, lessString);

    var out = std.ArrayList(u8).empty;
    defer out.deinit(allocator);

    try out.appendSlice(allocator, "[");
    for (sorted, 0..) |p, i| {
        if (i != 0) try out.appendSlice(allocator, ",");
        try out.appendSlice(allocator, p);
    }
    try out.appendSlice(allocator, "]");

    return out.toOwnedSlice(allocator);
}

test "permissions formatter is stable and short" {
    const allocator = std.testing.allocator;
    var perms = [_][]const u8{ "workspace.write", "workspace.read" };
    const out = try joinPermissions(allocator, perms[0..]);
    defer allocator.free(out);
    try std.testing.expectEqualStrings("[workspace.read,workspace.write]", out);
}

fn formatNoSkills(allocator: std.mem.Allocator) ![]const u8 {
    return allocator.dupe(
        u8,
        "No skills installed.\nnext: add a valid manifest at ~/.config/lan/skills/<skill-name>/manifest.json then rerun `lan skill list`.\n",
    );
}

fn tryListFromIndex(allocator: std.mem.Allocator, skills_root: []const u8) !?[]const u8 {
    const index_path = try std.fs.path.join(allocator, &[_][]const u8{ skills_root, "index.json" });
    defer allocator.free(index_path);

    const index_text = std.fs.cwd().readFileAlloc(allocator, index_path, 256 * 1024) catch return null;
    defer allocator.free(index_text);

    var parsed = std.json.parseFromSlice(IndexFile, allocator, index_text, .{}) catch return null;
    defer parsed.deinit();

    if (parsed.value.skills.len == 0) {
        return try formatNoSkills(allocator);
    }

    var out = std.ArrayList(u8).empty;
    defer out.deinit(allocator);

    for (parsed.value.skills) |s| {
        try out.writer(allocator).print("- name={s} version={s} perms={s} path={s}\n", .{ s.name, s.version, s.permissions, s.path });
    }

    const owned = try out.toOwnedSlice(allocator);
    return @as([]const u8, owned);
}

fn refreshIndexFromRoot(allocator: std.mem.Allocator, skills_root: []const u8) !void {
    var entries = std.ArrayList(IndexEntry).empty;
    defer {
        for (entries.items) |e| {
            allocator.free(e.name);
            allocator.free(e.version);
            allocator.free(e.path);
            allocator.free(e.permissions);
        }
        entries.deinit(allocator);
    }

    var dir = std.fs.cwd().openDir(skills_root, .{ .iterate = true }) catch |err| switch (err) {
        error.FileNotFound => {
            try std.fs.cwd().makePath(skills_root);
            try writeIndex(allocator, skills_root, &[_]IndexEntry{});
            return;
        },
        else => return err,
    };
    defer dir.close();

    var it = dir.iterate();
    while (try it.next()) |entry| {
        if (entry.kind != .directory) continue;

        const manifest_path = try std.fs.path.join(allocator, &[_][]const u8{ skills_root, entry.name, "manifest.json" });
        defer allocator.free(manifest_path);

        const text = std.fs.cwd().readFileAlloc(allocator, manifest_path, 64 * 1024) catch continue;
        defer allocator.free(text);

        var manifest = skill_manifest.parseAndValidate(allocator, text) catch continue;
        defer manifest.deinit(allocator);

        const perms = try joinPermissions(allocator, manifest.permissions);
        errdefer allocator.free(perms);

        try entries.append(allocator, .{
            .name = try allocator.dupe(u8, manifest.name),
            .version = try allocator.dupe(u8, manifest.version),
            .path = try allocator.dupe(u8, manifest_path),
            .permissions = perms,
        });
    }

    try writeIndex(allocator, skills_root, entries.items);
}

fn writeIndex(allocator: std.mem.Allocator, skills_root: []const u8, skills: []const IndexEntry) !void {
    const index_path = try std.fs.path.join(allocator, &[_][]const u8{ skills_root, "index.json" });
    defer allocator.free(index_path);

    var out = std.ArrayList(u8).empty;
    defer out.deinit(allocator);

    try out.appendSlice(allocator, "{\"skills\":[");
    for (skills, 0..) |s, i| {
        if (i != 0) try out.appendSlice(allocator, ",");
        try out.writer(allocator).print("{{\"name\":\"{s}\",\"version\":\"{s}\",\"path\":\"{s}\",\"permissions\":\"{s}\"}}", .{ s.name, s.version, s.path, s.permissions });
    }
    try out.appendSlice(allocator, "]}");

    const payload = try out.toOwnedSlice(allocator);
    defer allocator.free(payload);

    try std.fs.cwd().writeFile(.{ .sub_path = index_path, .data = payload });
}

pub fn listSkillsFromRoot(allocator: std.mem.Allocator, skills_root: []const u8) ![]const u8 {
    if (try tryListFromIndex(allocator, skills_root)) |from_index| {
        return from_index;
    }

    try refreshIndexFromRoot(allocator, skills_root);

    if (try tryListFromIndex(allocator, skills_root)) |from_refreshed_index| {
        return from_refreshed_index;
    }

    return try formatNoSkills(allocator);
}

test "skill list prefers index and falls back to scan when index invalid" {
    const allocator = std.testing.allocator;

    const tmp_root = try std.fmt.allocPrint(allocator, ".lan_skill_index_pref_{d}", .{std.time.timestamp()});
    defer allocator.free(tmp_root);
    std.fs.cwd().makeDir(tmp_root) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };
    defer std.fs.cwd().deleteTree(tmp_root) catch {};

    const skills_root = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "installed" });
    defer allocator.free(skills_root);

    const source_dir = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "source" });
    defer allocator.free(source_dir);
    try std.fs.cwd().makePath(source_dir);

    const source_manifest = try std.fs.path.join(allocator, &[_][]const u8{ source_dir, "manifest.json" });
    defer allocator.free(source_manifest);
    const manifest_text =
        \\{
        \\  "name": "demo-skill",
        \\  "version": "1.0.0",
        \\  "entry": "run.sh",
        \\  "tools": ["read"],
        \\  "permissions": ["workspace.read"]
        \\}
    ;
    try std.fs.cwd().writeFile(.{ .sub_path = source_manifest, .data = manifest_text });

    const add_out = try addSkillFromRoot(allocator, skills_root, source_dir);
    defer allocator.free(add_out);

    const skill_dir = try std.fs.path.join(allocator, &[_][]const u8{ skills_root, "demo-skill" });
    defer allocator.free(skill_dir);
    try std.fs.cwd().deleteTree(skill_dir);

    const from_index = try listSkillsFromRoot(allocator, skills_root);
    defer allocator.free(from_index);
    try std.testing.expect(std.mem.indexOf(u8, from_index, "name=demo-skill") != null);

    const index_path = try std.fs.path.join(allocator, &[_][]const u8{ skills_root, "index.json" });
    defer allocator.free(index_path);
    try std.fs.cwd().writeFile(.{ .sub_path = index_path, .data = "{" });

    const fallback = try listSkillsFromRoot(allocator, skills_root);
    defer allocator.free(fallback);
    try std.testing.expect(std.mem.indexOf(u8, fallback, "No skills installed") != null);
}

test "skill list returns actionable hint when empty" {
    const allocator = std.testing.allocator;

    const tmp_dir_name = try std.fmt.allocPrint(allocator, ".lan_skill_list_empty_{d}", .{std.time.timestamp()});
    defer allocator.free(tmp_dir_name);
    std.fs.cwd().makeDir(tmp_dir_name) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };
    defer std.fs.cwd().deleteTree(tmp_dir_name) catch {};

    const out = try listSkillsFromRoot(allocator, tmp_dir_name);
    defer allocator.free(out);
    try std.testing.expect(std.mem.indexOf(u8, out, "No skills installed") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "next:") != null);
}

test "skill add installs local manifest and becomes listable" {
    const allocator = std.testing.allocator;

    const tmp_root = try std.fmt.allocPrint(allocator, ".lan_skill_add_{d}", .{std.time.timestamp()});
    defer allocator.free(tmp_root);
    std.fs.cwd().makeDir(tmp_root) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };
    defer std.fs.cwd().deleteTree(tmp_root) catch {};

    const skills_root = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "installed" });
    defer allocator.free(skills_root);

    const source_dir = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "source" });
    defer allocator.free(source_dir);
    try std.fs.cwd().makePath(source_dir);

    const source_manifest = try std.fs.path.join(allocator, &[_][]const u8{ source_dir, "manifest.json" });
    defer allocator.free(source_manifest);

    const manifest_text =
        \\{
        \\  "name": "demo-skill",
        \\  "version": "1.0.0",
        \\  "entry": "run.sh",
        \\  "tools": ["read"],
        \\  "permissions": ["workspace.read"]
        \\}
    ;
    try std.fs.cwd().writeFile(.{ .sub_path = source_manifest, .data = manifest_text });

    const add_out = try addSkillFromRoot(allocator, skills_root, source_dir);
    defer allocator.free(add_out);
    try std.testing.expect(std.mem.indexOf(u8, add_out, "Skill installed") != null);
    try std.testing.expect(std.mem.indexOf(u8, add_out, "perms=[") != null);

    const list_out = try listSkillsFromRoot(allocator, skills_root);
    defer allocator.free(list_out);
    try std.testing.expect(std.mem.indexOf(u8, list_out, "name=demo-skill") != null);
    try std.testing.expect(std.mem.indexOf(u8, list_out, "perms=[") != null);
}

test "skill add returns next-step when manifest invalid" {
    const allocator = std.testing.allocator;

    const tmp_root = try std.fmt.allocPrint(allocator, ".lan_skill_add_invalid_{d}", .{std.time.timestamp()});
    defer allocator.free(tmp_root);
    std.fs.cwd().makeDir(tmp_root) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };
    defer std.fs.cwd().deleteTree(tmp_root) catch {};

    const skills_root = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "installed" });
    defer allocator.free(skills_root);

    const source_dir = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "source_invalid" });
    defer allocator.free(source_dir);
    try std.fs.cwd().makePath(source_dir);

    const source_manifest = try std.fs.path.join(allocator, &[_][]const u8{ source_dir, "manifest.json" });
    defer allocator.free(source_manifest);
    try std.fs.cwd().writeFile(.{ .sub_path = source_manifest, .data = "{\"name\":\"\"}" });

    const out = try addSkillFromRoot(allocator, skills_root, source_dir);
    defer allocator.free(out);
    try std.testing.expect(std.mem.indexOf(u8, out, "Skill install failed") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "next:") != null);
}

test "skill update changes visible version in list" {
    const allocator = std.testing.allocator;

    const tmp_root = try std.fmt.allocPrint(allocator, ".lan_skill_update_{d}", .{std.time.timestamp()});
    defer allocator.free(tmp_root);
    std.fs.cwd().makeDir(tmp_root) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };
    defer std.fs.cwd().deleteTree(tmp_root) catch {};

    const skills_root = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "installed" });
    defer allocator.free(skills_root);

    const src_v1 = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "src-v1" });
    defer allocator.free(src_v1);
    try std.fs.cwd().makePath(src_v1);
    const m1 = try std.fs.path.join(allocator, &[_][]const u8{ src_v1, "manifest.json" });
    defer allocator.free(m1);
    const manifest_v1 =
        \\{
        \\  "name": "demo-skill",
        \\  "version": "1.0.0",
        \\  "entry": "run.sh",
        \\  "tools": ["read"],
        \\  "permissions": ["workspace.read"]
        \\}
    ;
    try std.fs.cwd().writeFile(.{ .sub_path = m1, .data = manifest_v1 });

    const src_v2 = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "src-v2" });
    defer allocator.free(src_v2);
    try std.fs.cwd().makePath(src_v2);
    const m2 = try std.fs.path.join(allocator, &[_][]const u8{ src_v2, "manifest.json" });
    defer allocator.free(m2);
    const manifest_v2 =
        \\{
        \\  "name": "demo-skill",
        \\  "version": "1.1.0",
        \\  "entry": "run.sh",
        \\  "tools": ["read"],
        \\  "permissions": ["workspace.read"]
        \\}
    ;
    try std.fs.cwd().writeFile(.{ .sub_path = m2, .data = manifest_v2 });

    const add_out = try addSkillFromRoot(allocator, skills_root, src_v1);
    defer allocator.free(add_out);

    const upd_out = try updateSkillFromRoot(allocator, skills_root, src_v2);
    defer allocator.free(upd_out);
    try std.testing.expect(std.mem.indexOf(u8, upd_out, "Skill updated") != null);
    try std.testing.expect(std.mem.indexOf(u8, upd_out, "perms=[") != null);

    const list_out = try listSkillsFromRoot(allocator, skills_root);
    defer allocator.free(list_out);
    try std.testing.expect(std.mem.indexOf(u8, list_out, "version=1.1.0") != null);
    try std.testing.expect(std.mem.indexOf(u8, list_out, "perms=[") != null);
}

test "skill update returns next-step when target not installed" {
    const allocator = std.testing.allocator;

    const tmp_root = try std.fmt.allocPrint(allocator, ".lan_skill_update_nf_{d}", .{std.time.timestamp()});
    defer allocator.free(tmp_root);
    std.fs.cwd().makeDir(tmp_root) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };
    defer std.fs.cwd().deleteTree(tmp_root) catch {};

    const skills_root = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "installed" });
    defer allocator.free(skills_root);

    const src = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "src" });
    defer allocator.free(src);
    try std.fs.cwd().makePath(src);
    const m = try std.fs.path.join(allocator, &[_][]const u8{ src, "manifest.json" });
    defer allocator.free(m);
    const manifest_missing_target =
        \\{
        \\  "name": "demo-skill",
        \\  "version": "1.1.0",
        \\  "entry": "run.sh",
        \\  "tools": ["read"],
        \\  "permissions": ["workspace.read"]
        \\}
    ;
    try std.fs.cwd().writeFile(.{ .sub_path = m, .data = manifest_missing_target });

    const out = try updateSkillFromRoot(allocator, skills_root, src);
    defer allocator.free(out);
    try std.testing.expect(std.mem.indexOf(u8, out, "Skill update failed") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "next:") != null);
}

test "skill remove keeps list state consistent" {
    const allocator = std.testing.allocator;

    const tmp_root = try std.fmt.allocPrint(allocator, ".lan_skill_remove_{d}", .{std.time.timestamp()});
    defer allocator.free(tmp_root);
    std.fs.cwd().makeDir(tmp_root) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };
    defer std.fs.cwd().deleteTree(tmp_root) catch {};

    const skills_root = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "installed" });
    defer allocator.free(skills_root);

    const src_dir = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "source" });
    defer allocator.free(src_dir);
    try std.fs.cwd().makePath(src_dir);

    const src_manifest = try std.fs.path.join(allocator, &[_][]const u8{ src_dir, "manifest.json" });
    defer allocator.free(src_manifest);
    const manifest_text =
        \\{
        \\  "name": "demo-skill",
        \\  "version": "1.0.0",
        \\  "entry": "run.sh",
        \\  "tools": ["read"],
        \\  "permissions": ["workspace.read"]
        \\}
    ;
    try std.fs.cwd().writeFile(.{ .sub_path = src_manifest, .data = manifest_text });

    const add_out = try addSkillFromRoot(allocator, skills_root, src_dir);
    defer allocator.free(add_out);

    const rm_out = try removeSkillFromRoot(allocator, skills_root, "demo-skill");
    defer allocator.free(rm_out);
    try std.testing.expect(std.mem.indexOf(u8, rm_out, "Skill removed") != null);

    const list_out = try listSkillsFromRoot(allocator, skills_root);
    defer allocator.free(list_out);
    try std.testing.expect(std.mem.indexOf(u8, list_out, "No skills installed") != null);
}

test "skill remove shows hint when skill not found" {
    const allocator = std.testing.allocator;

    const tmp_root = try std.fmt.allocPrint(allocator, ".lan_skill_remove_nf_{d}", .{std.time.timestamp()});
    defer allocator.free(tmp_root);
    std.fs.cwd().makeDir(tmp_root) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };
    defer std.fs.cwd().deleteTree(tmp_root) catch {};

    const skills_root = try std.fs.path.join(allocator, &[_][]const u8{ tmp_root, "installed" });
    defer allocator.free(skills_root);

    const out = try removeSkillFromRoot(allocator, skills_root, "missing-skill");
    defer allocator.free(out);
    try std.testing.expect(std.mem.indexOf(u8, out, "Skill remove failed") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "next:") != null);
}

test "skill remove shows hint when skill name is invalid" {
    const allocator = std.testing.allocator;

    const out = try removeSkillFromRoot(allocator, ".", "../bad");
    defer allocator.free(out);
    try std.testing.expect(std.mem.indexOf(u8, out, "invalid name") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "next:") != null);
}

test "skill list includes name/version/path when installed" {
    const allocator = std.testing.allocator;

    const tmp_dir_name = try std.fmt.allocPrint(allocator, ".lan_skill_list_ok_{d}", .{std.time.timestamp()});
    defer allocator.free(tmp_dir_name);
    std.fs.cwd().makeDir(tmp_dir_name) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };
    defer std.fs.cwd().deleteTree(tmp_dir_name) catch {};

    const skill_dir = try std.fs.path.join(allocator, &[_][]const u8{ tmp_dir_name, "demo-skill" });
    defer allocator.free(skill_dir);
    try std.fs.cwd().makePath(skill_dir);

    const manifest_path = try std.fs.path.join(allocator, &[_][]const u8{ skill_dir, "manifest.json" });
    defer allocator.free(manifest_path);

    const manifest_text =
        \\{
        \\  "name": "demo-skill",
        \\  "version": "1.0.0",
        \\  "entry": "run.sh",
        \\  "tools": ["read"],
        \\  "permissions": ["workspace.read"]
        \\}
    ;
    try std.fs.cwd().writeFile(.{ .sub_path = manifest_path, .data = manifest_text });

    const out = try listSkillsFromRoot(allocator, tmp_dir_name);
    defer allocator.free(out);
    try std.testing.expect(std.mem.indexOf(u8, out, "name=demo-skill") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "version=1.0.0") != null);
    try std.testing.expect(std.mem.indexOf(u8, out, "path=") != null);
}
