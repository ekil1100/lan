const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const version = b.option([]const u8, "version", "CLI version") orelse "0.1.0";
    const commit = b.option([]const u8, "commit", "Git short SHA") orelse "dev";
    const build_time = b.option([]const u8, "build-time", "Build timestamp") orelse "unknown";

    const build_info = b.addOptions();
    build_info.addOption([]const u8, "version", version);
    build_info.addOption([]const u8, "commit", commit);
    build_info.addOption([]const u8, "build_time", build_time);

    const root_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    root_mod.addOptions("build_info", build_info);

    // Main executable
    const exe = b.addExecutable(.{
        .name = "lan",
        .root_module = root_mod,
    });

    b.installArtifact(exe);

    // Run command
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Tests
    const exe_unit_tests = b.addTest(.{
        .root_module = root_mod,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
