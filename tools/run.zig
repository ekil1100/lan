const std = @import("std");

const RunMode = enum {
    auto,
    background,
};

const TaskType = enum {
    build,
    test_task,
    dangerous,
    normal,
};

fn classifyCommand(cmd: []const u8) TaskType {
    const dangerous = &[_][]const u8{
        "deploy", "release", "rm -rf", "rm -r /", "sudo",
        "dd ", "mkfs", "fdisk", "drop", "delete",
    };
    
    for (dangerous) |d| {
        if (std.mem.indexOf(u8, cmd, d) != null) {
            return .dangerous;
        }
    }
    
    if (std.mem.indexOf(u8, cmd, "build") != null or
        std.mem.indexOf(u8, cmd, "compile") != null or
        std.mem.indexOf(u8, cmd, "make") != null) {
        return .build;
    }
    
    if (std.mem.indexOf(u8, cmd, "test") != null) {
        return .test_task;
    }
    
    return .normal;
}

fn parseArgs(args: [][]const u8) struct { mode: RunMode, cmd: []const u8 } {
    if (args.len < 2) {
        std.debug.print("Usage: run [!b|!后台] <command>\n", .{});
        std.process.exit(1);
    }
    
    const first = args[1];
    
    if (std.mem.eql(u8, first, "!b") or std.mem.eql(u8, first, "!后台")) {
        const cmd = std.mem.join(std.heap.page_allocator, " ", args[2..]) catch "";
        return .{ .mode = .background, .cmd = cmd };
    }
    
    const cmd = std.mem.join(std.heap.page_allocator, " ", args[1..]) catch "";
    return .{ .mode = .auto, .cmd = cmd };
}

const ChildPtr = struct {
    ptr: *std.process.Child,
    killed: bool,
};

fn timeoutKiller(child_ptr: *ChildPtr, timeout_ms: u64) void {
    std.time.sleep(timeout_ms * std.time.ns_per_ms);
    _ = child_ptr.ptr.kill() catch {};
    child_ptr.killed = true;
}

fn runWithTimeout(allocator: std.mem.Allocator, cmd: []const u8, timeout_ms: u64) !bool {
    const argv = &[_][]const u8{"sh", "-c", cmd};
    
    var child = std.process.Child.init(argv, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    
    try child.spawn();
    
    var child_ptr = ChildPtr{
        .ptr = &child,
        .killed = false,
    };
    
    // 启动超时线程
    const timeout_thread = try std.Thread.spawn(.{}, timeoutKiller, .{&child_ptr, timeout_ms});
    timeout_thread.detach();
    
    var stdout = std.ArrayList(u8).init(allocator);
    var stderr = std.ArrayList(u8).init(allocator);
    defer stdout.deinit();
    defer stderr.deinit();
    
    // 收集输出 - 这会阻塞直到进程结束或被 kill
    child.collectOutput(&stdout, &stderr, 10 * 1024 * 1024) catch {
        // 可能被 kill 了，继续检查
    };
    
    // 尝试等待进程（可能已经结束了）
    const term = child.wait() catch {
        // 被 kill 了
        if (child_ptr.killed) {
            std.debug.print("\n[!] 任务超过 10 秒，已中断\n", .{});
            std.debug.print("[!] 自动转为后台执行...\n", .{});
            return false;
        }
        return true; // 其他错误但可能完成了
    };
    _ = term;
    
    // 打印输出
    std.debug.print("{s}", .{stdout.items});
    std.debug.print("{s}", .{stderr.items});
    
    if (child_ptr.killed) {
        return false;
    }
    
    std.debug.print("\n[ok] 任务完成\n", .{});
    return true;
}

fn spawnBackground(allocator: std.mem.Allocator, cmd: []const u8) !void {
    std.debug.print("[->] 启动后台任务: {s}\n", .{cmd});
    
    const cwd = std.fs.cwd().realpathAlloc(allocator, ".") catch ".";
    defer allocator.free(cwd);
    
    var script_buf: [4096]u8 = undefined;
    const script = try std.fmt.bufPrint(
        &script_buf,
        "#!/bin/bash\ncd \"{s}\"\necho \"[后台开始] {s}\"\n{s}\necho \"[后台结束] 退出码: $?\"\n",
        .{ cwd, cmd, cmd }
    );
    
    const script_path = "/tmp/run-bg.sh";
    try std.fs.cwd().writeFile(.{ .sub_path = script_path, .data = script });
    
    _ = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{"chmod", "+x", script_path},
    }) catch {};
    
    var child = std.process.Child.init(
        &[_][]const u8{"nohup", "bash", script_path},
        allocator,
    );
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;
    
    try child.spawn();
    _ = child.wait() catch {};
    
    std.debug.print("[ok] 已在后台运行\n", .{});
    std.debug.print("[i] 查看脚本: cat /tmp/run-bg.sh\n", .{});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    
    const parsed = parseArgs(args);
    const cmd = parsed.cmd;
    const mode = parsed.mode;
    
    if (cmd.len == 0) {
        std.debug.print("Error: no command\n", .{});
        std.process.exit(1);
    }
    
    std.debug.print("[>] {s}\n", .{cmd});
    
    switch (mode) {
        .background => {
            try spawnBackground(allocator, cmd);
        },
        
        .auto => {
            const task_type = classifyCommand(cmd);
            
            switch (task_type) {
                .dangerous => {
                    std.debug.print("[!] 危险操作，强制后台\n", .{});
                    try spawnBackground(allocator, cmd);
                },
                
                .build, .test_task, .normal => {
                    std.debug.print("[i] 尝试执行（10秒超时）...\n", .{});
                    
                    const completed = runWithTimeout(allocator, cmd, 10_000) catch |err| {
                        std.debug.print("[x] 失败: {s}\n", .{@errorName(err)});
                        std.process.exit(1);
                    };
                    
                    if (!completed) {
                        try spawnBackground(allocator, cmd);
                    }
                },
            }
        },
    }
}
