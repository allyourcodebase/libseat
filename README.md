# libseat zig

[seatd/libseat](https://git.sr.ht/~kennylevinsen/seatd), packaged for the Zig build system.

Built with the seatd backend (no logind/systemd dependency).

## Using

First, update your `build.zig.zon`:

```
zig fetch --save git+https://github.com/allyourcodebase/libseat.git
```

Then in your `build.zig`:

```zig
const libseat = b.dependency("libseat", .{ .target = target, .optimize = optimize });
exe.linkLibrary(libseat.artifact("seat"));
```
