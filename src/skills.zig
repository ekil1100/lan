const std = @import("std");
const skill_manifest = @import("skill_manifest.zig");

pub fn listSkills(allocator: std.mem.Allocator, config_dir: []const u8) ![]const u8 {
    const skills_root = try std.fs.path.join(allocator, &[_][]const u8{ config_dir, "skills" });
    defer allocator.free(skills_root);
    return listSkillsFromRoot(allocator, skills_root);
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
