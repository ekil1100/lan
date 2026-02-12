const std = @import("std");
const tui = @import("tui.zig");
const Agent = @import("agent.zig").Agent;
const Config = @import("config.zig").Config;
const _skill_manifest = @import("skill_manifest.zig");
const skills = @import("skills.zig");
const build_info = @import("build_info");
const logger = @import("log.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len >= 2 and (std.mem.eql(u8, args[1], "help") or std.mem.eql(u8, args[1], "--help") or std.mem.eql(u8, args[1], "-h"))) {
        var hb: [4096]u8 = undefined;
        var hw = std.fs.File.stdout().writer(&hb);
        try hw.interface.writeAll(
            \\lan — a fast, skill-native agent CLI/TUI
            \\
            \\Usage: lan [command] [options]
            \\
            \\Commands:
            \\  (none)             Start interactive TUI session
            \\  help               Show this help message
            \\  --version          Show version, commit, and build time
            \\  config init        Generate default config file
            \\  skill list         List installed skills
            \\  skill add <dir>    Install skill from local directory
            \\  skill update <dir> Update installed skill from local directory
            \\  skill remove <name> Remove installed skill by name
            \\  history export     Export session history as JSON
            \\  history search <q> Search history by keyword (JSON output)
            \\  history clear      Clear session history
            \\
            \\Diagnostics (scripts):
            \\  ./scripts/lan-doctor.sh       Run comprehensive diagnostics
            \\  ./scripts/preflight.sh <dir>  Pre-install environment check
            \\  ./scripts/support-bundle.sh   Generate support bundle
            \\
            \\Documentation: docs/
            \\
        );
        try hw.interface.flush();
        return;
    }

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

    // lan config init — generate default config from template
    if (args.len >= 3 and std.mem.eql(u8, args[1], "config") and std.mem.eql(u8, args[2], "init")) {
        var cfg_i = try Config.load(allocator);
        defer cfg_i.deinit();
        const cp = try std.fs.path.join(allocator, &[_][]const u8{ cfg_i.config_dir, "config.json" });
        defer allocator.free(cp);
        // Check if config already exists and has content
        const existing = std.fs.cwd().readFileAlloc(allocator, cp, 64 * 1024) catch null;
        if (existing) |e| {
            allocator.free(e);
            if (e.len > 2) {
                var ib: [256]u8 = undefined;
                var iw = std.fs.File.stdout().writer(&ib);
                try iw.interface.print("Config already exists at {s} — skipping.\nnext: edit manually or delete and rerun `lan config init`.\n", .{cp});
                try iw.interface.flush();
                return;
            }
        }
        const template = "{\"provider\":{\"url\":\"https://api.openai.com\",\"api_key\":\"\",\"model\":\"gpt-4\"},\"route\":{\"mode\":\"speed\",\"fallback\":[]},\"skills\":{\"dir\":\"~/.config/lan/skills\"}}";
        const f = try std.fs.cwd().createFile(cp, .{});
        defer f.close();
        var fb: [4096]u8 = undefined;
        var fw = f.writer(&fb);
        try fw.interface.writeAll(template);
        try fw.interface.writeAll("\n");
        try fw.interface.flush();
        var ob: [512]u8 = undefined;
        var ow2 = std.fs.File.stdout().writer(&ob);
        try ow2.interface.print("Config initialized at {s}\nnext: edit provider.api_key and provider.url to match your setup.\n", .{cp});
        try ow2.interface.flush();
        return;
    }

    // lan history clear — delete history file
    if (args.len >= 3 and std.mem.eql(u8, args[1], "history") and std.mem.eql(u8, args[2], "clear")) {
        var cfg_c = try Config.load(allocator);
        defer cfg_c.deinit();
        const hpc = try std.fs.path.join(allocator, &[_][]const u8{ cfg_c.config_dir, "history.json" });
        defer allocator.free(hpc);
        std.fs.cwd().deleteFile(hpc) catch {};
        // Write empty array so export returns []
        const f = try std.fs.cwd().createFile(hpc, .{});
        defer f.close();
        var cbuf: [256]u8 = undefined;
        var cw = f.writer(&cbuf);
        try cw.interface.writeAll("[]\n");
        try cw.interface.flush();
        var obuf: [256]u8 = undefined;
        var ow = std.fs.File.stdout().writer(&obuf);
        try ow.interface.writeAll("History cleared.\n");
        try ow.interface.flush();
        return;
    }

    // lan history search <keyword> — filter history by keyword
    if (args.len >= 4 and std.mem.eql(u8, args[1], "history") and std.mem.eql(u8, args[2], "search")) {
        const keyword = args[3];
        var cfg_s = try Config.load(allocator);
        defer cfg_s.deinit();
        const hp = try std.fs.path.join(allocator, &[_][]const u8{ cfg_s.config_dir, "history.json" });
        defer allocator.free(hp);
        const raw = std.fs.cwd().readFileAlloc(allocator, hp, 4 * 1024 * 1024) catch |err| {
            var eb: [4096]u8 = undefined;
            var ew2 = std.fs.File.stdout().writer(&eb);
            try ew2.interface.print("History search failed: {s}\nnext: ensure a session has been run at least once.\n", .{@errorName(err)});
            try ew2.interface.flush();
            return;
        };
        defer allocator.free(raw);

        // Simple line-based search: output matching JSON objects
        var sb: [8192]u8 = undefined;
        var sw = std.fs.File.stdout().writer(&sb);
        try sw.interface.writeAll("[\n");
        var first = true;
        var i: usize = 0;
        while (i < raw.len) {
            // Find each {"role": line
            if (std.mem.startsWith(u8, raw[i..], "{\"role\":") or
                (i + 2 < raw.len and raw[i] == ' ' and raw[i + 1] == ' ' and std.mem.startsWith(u8, raw[i + 2..], "{\"role\":")))
            {
                // Find end of this JSON object line
                var end = i;
                while (end < raw.len and raw[end] != '\n') : (end += 1) {}
                const line = raw[i..end];
                // Strip trailing comma if present
                const trimmed = if (line.len > 0 and line[line.len - 1] == ',') line[0 .. line.len - 1] else line;
                // Check if keyword appears in line (case-sensitive)
                if (std.mem.indexOf(u8, trimmed, keyword) != null) {
                    if (!first) try sw.interface.writeAll(",\n");
                    first = false;
                    // Trim leading whitespace
                    var start: usize = 0;
                    while (start < trimmed.len and (trimmed[start] == ' ' or trimmed[start] == '\t')) : (start += 1) {}
                    try sw.interface.writeAll(trimmed[start..]);
                }
                i = end + 1;
            } else {
                i += 1;
            }
        }
        try sw.interface.writeAll("\n]\n");
        try sw.interface.flush();
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
