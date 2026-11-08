# libvpx for Nintendo Switch (NEON)

`lib/libvpx.a` is libvpx **1.8.0** built for the Switch with the AArch64 NEON
assembly enabled:

```
--target=arm64-linux-gcc --enable-vp8 --disable-vp9
--extra-cflags="-O3 -fPIC"
```

## Why a custom build?

The devkitPro `switch-libvpx` package is configured with
`--target=generic-gnu`, which produces a pure C library with **no NEON
assembly** (the archive contains zero NEON symbols). Software VP8 decode at
1920x1080 is far too slow on the Switch with that build. The NEON build in
this directory decodes retail 1080p30 video in real time.

`-fPIC` is required because libnx links the homebrew as a PIE executable; the
generic-C library happens to avoid text relocations, but the NEON assembly
needs position-independent code.

## Rebuild

From WSL with devkitPro installed:

```sh
./deps/build_libvpx.sh
```

The script downloads libvpx 1.8.0, applies `libvpx.patch` (devkitPro's fixes
for the bare-metal toolchain), builds it, and replaces `lib/libvpx.a`.

The Makefile puts `deps` before the devkitPro portlibs in `LIBDIRS`, so this
archive is used instead of the packaged one.
