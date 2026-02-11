const std = @import("std");
const tui = @import("tui.zig");
const Agent = @import("agent.zig").Agent;
const Config = @import("config.zig").Config;
const _skill_manifest = @import("skill_manifest.zig");
const skills = @import("skills.zig");
const build_info = @import("build_info");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len >= 2 and std.mem.eql(u8, args[1], "--version")) {
        var buf: [4096]u8 = undefined;
        var writer = std.fs.File.stdout().writer(&buf);
        try writer.interface.print("lan version={s} commit={s} build_time={s}\n", .{ build_info.version, build_info.commit, build_info.build_time });
        try writer.interface.flush();
        return;
    }

    if (args.len >= 3 and std.mem.eql(u8, args[1], "skill") and std.mem.eql(u8, args[2], "list")) {
        var config = try Config.load(allocator);
        defer config.deinit();

        const output = try skills.listSkills(allocator, config.config_dir);
        defer allocator.free(output);

        var buf: [4096]u8 = undefined;
        var writer = std.fs.File.stdout().writer(&buf);
        try writer.interface.print("{s}", .{output});
        try writer.interface.flush();
        return;
    }

    if (args.len >= 3 and std.mem.eql(u8, args[1], "skill") and std.mem.eql(u8, args[2], "add")) {
        var buf: [4096]u8 = undefined;
        var writer = std.fs.File.stdout().writer(&buf);

        if (args.len < 4) {
            try writer.interface.print("Skill install failed: missing path\nnext: run `lan skill add <local-dir>`\n", .{});
            try writer.interface.flush();
            return;
        }

        var config = try Config.load(allocator);
        defer config.deinit();

        const output = try skills.addSkill(allocator, config.config_dir, args[3]);
        defer allocator.free(output);

        try writer.interface.print("{s}", .{output});
        try writer.interface.flush();
        return;
    }

    if (args.len >= 3 and std.mem.eql(u8, args[1], "skill") and std.mem.eql(u8, args[2], "update")) {
        var buf: [4096]u8 = undefined;
        var writer = std.fs.File.stdout().writer(&buf);

        if (args.len < 4) {
            try writer.interface.print("Skill update failed: missing path\nnext: run `lan skill update <local-dir>`\n", .{});
            try writer.interface.flush();
            return;
        }

        var config = try Config.load(allocator);
        defer config.deinit();

        const output = try skills.updateSkill(allocator, config.config_dir, args[3]);
        defer allocator.free(output);

        try writer.interface.print("{s}", .{output});
        try writer.interface.flush();
        return;
    }

    if (args.len >= 3 and std.mem.eql(u8, args[1], "skill") and std.mem.eql(u8, args[2], "remove")) {
        var buf: [4096]u8 = undefined;
        var writer = std.fs.File.stdout().writer(&buf);

        if (args.len < 4) {
            try writer.interface.print("Skill remove failed: missing name\nnext: run `lan skill remove <name>`\n", .{});
            try writer.interface.flush();
            return;
        }

        var config = try Config.load(allocator);
        defer config.deinit();

        const output = try skills.removeSkill(allocator, config.config_dir, args[3]);
        defer allocator.free(output);

        try writer.interface.print("{s}", .{output});
        try writer.interface.flush();
        return;
    }

    // lan history export — dump history as JSON with role/content/timestamp
    if (args.len >= 3 and std.mem.eql(u8, args[1], "history") and std.mem.eql(u8, args[2], "export")) {
        var cfg = try Config.load(allocator);
        defer cfg.deinit();
        const history_path = try std.fs.path.join(allocator, &[_][]const u8{ cfg.config_dir, "history.json" });
        defer allocator.free(history_path);
        const content = std.fs.cwd().readFileAlloc(allocator, history_path, 4 * 1024 * 1024) catch |err| {
            var ebuf: [4096]u8 = undefined;
            var ew = std.fs.File.stdout().writer(&ebuf);
            try ew.interface.print("History export failed: {s}\nnext: ensure a session has been run at least once.\n", .{@errorName(err)});
            try ew.interface.flush();
            return;
        };
        defer allocator.free(content);
        var hbuf: [4096]u8 = undefined;
        var hw = std.fs.File.stdout().writer(&hbuf);
        try hw.interface.print("{s}", .{content});
        try hw.interface.flush();
        return;
    }

    var config = try Config.load(allocator);
    defer config.deinit();

    var agent = try Agent.init(allocator, &config);
    defer agent.deinit();

    var app = try tui.App.init(allocator, &agent);
    defer app.deinit();

    try app.run();
}
