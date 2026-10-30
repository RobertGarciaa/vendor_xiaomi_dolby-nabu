#!/usr/bin/env python3
"""Retarget the stock libqtigef GEF HAL lookup from msmnile to nabu.

Why this exists
---------------
The stock ARM32 `libqtigef.so` builds its audio-HAL path at runtime from a
hard-coded platform string:

    /vendor/lib/hw/audio.primary.%s.so      +  "msmnile"

The nabu vendor tree renames its single stock HAL to `audio.primary.nabu.so`
(`ro.hardware.audio.primary=nabu`, and `proprietary-files.txt` applies
FIX_SONAME). On nabu the GEF path therefore pointed at
`audio.primary.msmnile.so`, which does not exist in the shipping image.
`gef_register_session` calls `access()` then `dlopen()` on that path and, when it
fails, `gef_set_param_v1` has no HAL transfer function to call and returns -38.

Two ways to fix it:

  1. install a compatibility symlink at `audio.primary.msmnile.so`, or
  2. make GEF ask for the HAL it actually runs inside.

Option 1 collides with the qcom-caf source HAL, which also installs to exactly
that path, and Kati then reports "overriding commands for target
vendor/lib/hw/audio.primary.msmnile.so". Option 1 also risks a second HAL
instance being loaded instead of the one AudioFlinger already owns.

This tool implements option 2. It rewrites the single platform literal so GEF
resolves `/vendor/lib/hw/audio.primary.nabu.so`, i.e. the very binary the audio
HAL service already loaded. `dlopen` of an already-loaded library returns the
same handle, so GEF shares the HAL's device context instead of duplicating it.

Safety
------
"msmnile" is seven bytes, "nabu" is four. The replacement is NUL-padded to keep
every file offset, the ELF size, all section/program headers and the whole
instruction stream byte-identical; only the string contents differ. The tool
asserts that and pins both the input and output hashes, so a different stock
build is rejected rather than silently patched in the wrong place.

The patched library is nabu-specific and is never installed for other sm8150
devices: it ships from vendor/xiaomi/dolby-nabu and only that product inherits it.
"""
import argparse
import hashlib
import struct
from pathlib import Path

INPUT_SHA256 = 'ccac6350e59bda509c6fce8ce07355a81aa916e4b5313e1710b7b22f98732d42'
OUTPUT_SHA256 = '2a91c5d827184a4fdcc86783d05c2fac20ad0454bea1821945977b496c38d0a8'
OLD_PLATFORM = b'msmnile'
NEW_PLATFORM = b'nabu'
RELATIVE_PATH = '/vendor/lib/hw/audio.primary.%s.so'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def check_elf32_arm(data):
    if data[:4] != b'\x7fELF':
        raise ValueError('Not an ELF file')
    if data[4] != 1:
        raise ValueError('Expected ELF32 (stock libqtigef is 32-bit only)')
    if data[5] != 1:
        raise ValueError('Expected little-endian ELF')
    e_machine = struct.unpack_from('<H', data, 18)[0]
    if e_machine != 40:
        raise ValueError(f'Expected EM_ARM (40), found {e_machine}')


def patch(data):
    if digest(data) != INPUT_SHA256:
        raise ValueError(
            'Unexpected libqtigef input; refusing to patch.\n'
            f'  expected {INPUT_SHA256}\n  actual   {digest(data)}')

    check_elf32_arm(data)

    if data.count(OLD_PLATFORM) != 1:
        raise ValueError('Expected exactly one "msmnile" literal')
    if data.count(RELATIVE_PATH.encode()) != 1:
        raise ValueError('Expected exactly one HAL path format string')

    offset = data.find(OLD_PLATFORM)
    # The literal must be NUL-terminated so it is a standalone C string.
    if data[offset + len(OLD_PLATFORM)] != 0:
        raise ValueError('Platform literal is not NUL-terminated')

    span = len(OLD_PLATFORM) + 1  # include the terminator
    padded = NEW_PLATFORM + b'\x00' * (span - len(NEW_PLATFORM))
    patched = bytearray(data)
    patched[offset:offset + span] = padded
    patched = bytes(patched)

    if len(patched) != len(data):
        raise ValueError('Patch changed the file length')
    if digest(patched) != OUTPUT_SHA256:
        raise ValueError(
            'Patched output hash mismatch; the replacement changed more than '
            f'the platform literal.\n  expected {OUTPUT_SHA256}\n'
            f'  actual   {digest(patched)}')
    return patched, offset


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--input', required=True, type=Path,
                   help='stock ARM32 libqtigef.so from sm8150-common')
    p.add_argument('--output', required=True, type=Path)
    a = p.parse_args()

    data = a.input.read_bytes()
    patched, offset = patch(data)
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_bytes(patched)
    print(f'patched {a.input} -> {a.output}')
    print(f'  platform literal at {offset:#x}: '
          f'{OLD_PLATFORM.decode()} -> {NEW_PLATFORM.decode()} (NUL padded)')
    print(f'  size unchanged ({len(patched)} bytes)')
    print(f'  output sha256 {digest(patched)}')


if __name__ == '__main__':
    main()
