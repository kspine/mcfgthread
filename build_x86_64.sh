#!/bin/sh

set -e

prefix="$(pwd)/release/mingw64"
mkdir -p "$prefix"

builddir="$(pwd)/build_x86_64"
mkdir -p "$builddir"

build=x86_64-w64-mingw32

echo Building shared library...
mkdir -p m4
autoreconf -i
(cd "$builddir" &&
  CPPFLAGS='-DNDEBUG'	\
  CFLAGS='-O3 -ffunction-sections -fdata-sections'	\
  LDFLAGS='-Wl,-s,--gc-sections'	\
  ../configure --build="$build" --host="$build" --prefix="$prefix" && make -j4)

echo Testing...
cp -p "$builddir/lib/libmcfgthread.dll.a" "$builddir/lib/libmcfgthread-new.dll.a"
("$build"-gcc -std=c11 -Wall -Wextra -Wpedantic -Werror test/test.c -Isrc/env -L"$builddir/lib" -lmcfgthread-new -o test.exe &&
  PATH="$builddir/bin:$PATH" ./test.exe)

(cd "$builddir" &&
  make install)
