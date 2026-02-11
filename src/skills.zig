const std = @import("std");
const skill_manifest = @import("skill_manifest.zig");

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

pub fn addSkillFromRoot(allocator: std.mem.Allocator, skills_root: []const u8, source_dir: []const u8) ![]const u8 {
    const src_manifest = try std.fs.path.join(allocator, &[_][]const u8{ source_dir, "manifest.json" });
    defer allocator.free(src_manifest);

    const src_text = std.fs.cwd().readFileAlloc(allocator, src_manifest, 64 * 1024) catch {
        return allocator.dupe(u8,
            "Skill install failed: missing manifest.json\nnext: provide a local folder containing manifest.json and retry `lan skill add <path>`.\n",
        );
    };
    defer allocator.free(src_text);

    var manifest = skill_manifest.parseAndValidate(allocator, src_text) catch {
        return allocator.dupe(u8,
            "Skill install failed: invalid manifest schema\nnext: ensure name/version/entry/tools/permissions are valid, then retry.\n",
        );
    };
    defer manifest.deinit(allocator);

    try std.fs.cwd().makePath(skills_root);

    const dst_dir = try std.fs.path.join(allocator, &[_][]const u8{ skills_root, manifest.name });
    defer allocator.free(dst_dir);
    try std.fs.cwd().makePath(dst_dir);

    const dst_manifest = try std.fs.path.join(allocator, &[_][]const u8{ dst_dir, "manifest.json" });
    defer allocator.free(dst_manifest);
    try std.fs.cwd().writeFile(.{ .sub_path = dst_manifest, .data = src_text });

    return std.fmt.allocPrint(allocator, "Skill installed: name={s} version={s} path={s}\n", .{ manifest.name, manifest.version, dst_manifest });
}

pub fn listSkillsFromRoot(allocator: std.mem.Allocator, skills_root: []const u8) ![]const u8 {
    var out = std.ArrayList(u8).empty;
    defer out.deinit(allocator);

    var dir = std.fs.cwd().openDir(skills_root, .{ .iterate = true }) catch |err| switch (err) {
        error.FileNotFound => {
            return allocator.dupe(u8,
                "No skills installed.\nnext: create ~/.config/lan/skills/<skill-name>/manifest.json then run `lan skill list` again.\n",
            );
        },
        else => return err,
    };
    defer dir.close();

    var it = dir.iterate();
    var count: usize = 0;

    while (try it.next()) |entry| {
        if (entry.kind != .directory) continue;

        const manifest_path = try std.fs.path.join(allocator, &[_][]const u8{ skills_root, entry.name, "manifest.json" });
        defer allocator.free(manifest_path);

        const text = std.fs.cwd().readFileAlloc(allocator, manifest_path, 64 * 1024) catch continue;
        defer allocator.free(text);

        var manifest = skill_manifest.parseAndValidate(allocator, text) catch continue;
        defer manifest.deinit(allocator);

        try out.writer(allocator).print("- name={s} version={s} path={s}\n", .{ manifest.name, manifest.version, manifest_path });
        count += 1;
    }

    if (count == 0) {
        return allocator.dupe(u8,
            "No skills installed.\nnext: add a valid manifest at ~/.config/lan/skills/<skill-name>/manifest.json then rerun `lan skill list`.\n",
        );
    }

    return out.toOwnedSlice(allocator);
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

    const list_out = try listSkillsFromRoot(allocator, skills_root);
    defer allocator.free(list_out);
    try std.testing.expect(std.mem.indexOf(u8, list_out, "name=demo-skill") != null);
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
