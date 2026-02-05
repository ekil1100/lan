const std = @import("std");
const tui = @import("tui.zig");
const Agent = @import("agent.zig").Agent;
const Config = @import("config.zig").Config;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var config = try Config.load(allocator);
    var agent = try Agent.init(allocator, &config);
    var app = try tui.App.init(allocator, &agent);

    app.run() catch |err| {
        app.deinit();
        agent.deinit();
        config.deinit();
        _ = gpa.deinit();
        return err;
    };

    app.deinit();
    agent.deinit();
    config.deinit();
    _ = gpa.deinit();
}