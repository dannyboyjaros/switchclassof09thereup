#!/usr/bin/env bash
# Build libvpx 1.8.0 for the Nintendo Switch with NEON enabled and install it
# as deps/lib/libvpx.a.  Run from WSL with devkitPro installed.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${BUILD_DIR:-$HOME/libvpx-arm64-build}"
VER="1.8.0"

source /etc/profile.d/devkit-env.sh
export DEVKITPRO=/opt/devkitpro
export PATH=/opt/devkitpro/tools/bin:/opt/devkitpro/devkitA64/bin:$PATH

mkdir -p "$WORK"
cd "$WORK"

if [ ! -d "libvpx-$VER" ]; then
    wget -q "https://github.com/webmproject/libvpx/archive/v$VER.tar.gz" -O "v$VER.tar.gz"
    tar xzf "v$VER.tar.gz"
fi

cd "libvpx-$VER"
if [ ! -f .patched ]; then
    patch -p1 < "$ROOT/deps/libvpx.patch"
    touch .patched
fi

make clean >/dev/null 2>&1 || true

# arm64-linux-gcc enables the AArch64 NEON assembly paths.
# -fPIC is required because libnx links a PIE executable.
CROSS=aarch64-none-elf- ./configure \
    --target=arm64-linux-gcc \
    --prefix="$WORK/prefix" \
    --disable-examples --disable-tools --disable-docs --disable-unit-tests \
    --disable-shared --enable-static \
    --enable-vp8 --disable-vp9 \
    --disable-webm-io --disable-libyuv \
    --extra-cflags="-O3 -fPIC"

make -j"$(nproc)"

mkdir -p "$ROOT/deps/lib"
cp libvpx.a "$ROOT/deps/lib/libvpx.a"
echo "Wrote $ROOT/deps/lib/libvpx.a"
