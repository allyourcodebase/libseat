const std = @import("std");

const manifest = @import("build.zig.zon");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const options = .{
        .linkage = b.option(std.builtin.LinkMode, "linkage", "Library linkage type") orelse .static,
        .defaultpath = b.option([]const u8, "defaultpath", "seatd socket path") orelse
            if (target.result.os.tag == .linux) "/run/seatd.sock" else "/var/run/seatd.sock",
    };

    const upstream = b.dependency("libseat_c", .{});

    const mod = b.createModule(.{ .target = target, .optimize = optimize, .link_libc = true });
    mod.addIncludePath(upstream.path(""));
    mod.addIncludePath(upstream.path("include"));
    mod.addCMacro("_XOPEN_SOURCE", "700");
    mod.addCMacro("__BSD_VISIBLE", "");
    mod.addCMacro("_NETBSD_SOURCE", "");
    mod.addCMacro("LIBSEAT", "1");
    mod.addCMacro("SEATD_ENABLED", "1");
    mod.addCMacro("SEATD_VERSION", b.fmt("\"{s}\"", .{manifest.version}));
    mod.addCMacro("SEATD_DEFAULTPATH", b.fmt("\"{s}\"", .{options.defaultpath}));
    mod.addCSourceFiles(.{
        .root = upstream.path(""),
        .files = srcs,
        .flags = flags,
    });

    const lib = b.addLibrary(.{
        .name = "seat",
        .root_module = mod,
        .linkage = options.linkage,
        .version = try .parse(manifest.version),
    });
    if (options.linkage == .dynamic) lib.version_script = upstream.path("libseat/libseat.syms");
    lib.installHeader(upstream.path("include/libseat.h"), "libseat.h");
    b.installArtifact(lib);
}

const flags: []const []const u8 = &.{
    "-Uunix",
    "-fvisibility=hidden",
};

const srcs: []const []const u8 = &.{
    "common/connection.c",
    "common/linked_list.c",
    "common/log.c",
    "libseat/backend/seatd.c",
    "libseat/libseat.c",
    "libseat/backend/noop.c",
};
