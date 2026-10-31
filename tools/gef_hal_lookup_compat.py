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

Both ABIs are shipped. The stock vendor image carries a 32-bit and a 64-bit
libqtigef.so, and vendor/lib64/soundfx/libhwdap.so dlopen()s "libqtigef.so"
expecting the 64-bit one; without it that dlopen returns NULL and libhwdap
aborts on __android_log_assert. Both copies contain the same "msmnile" literal
and get the same offset-neutral rewrite.
"""
import argparse
import hashlib
import struct
from pathlib import Path

# Per-ABI pinned inputs and outputs; a file must match exactly one profile.
PROFILES = {
    1: {  # ELF32, EM_ARM
        'input': 'ccac6350e59bda509c6fce8ce07355a81aa916e4b5313e1710b7b22f98732d42',
        'output': '2a91c5d827184a4fdcc86783d05c2fac20ad0454bea1821945977b496c38d0a8',
        'machine': 40,
        'name': 'ARM32',
    },
    2: {  # ELF64, EM_AARCH64
        'input': '68419da3cf8add49bd7fa21db9cc793c0ff1db1f474da3f9b454e9a413166829',
        'output': 'b80cd836afd81e9ed466e2e9268cb2251703f5fe33f1d0cb26f8aefaedb4fe83',
        'machine': 183,
        'name': 'ARM64',
    },
}
OLD_PLATFORM = b'msmnile'
NEW_PLATFORM = b'nabu'
RELATIVE_PATH = '/vendor/lib/hw/audio.primary.%s.so'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def check_elf(data):
    if data[:4] != b'\x7fELF':
        raise ValueError('Not an ELF file')
    if data[5] != 1:
        raise ValueError('Expected little-endian ELF')
    elf_class = data[4]
    profile = PROFILES.get(elf_class)
    if profile is None:
        raise ValueError(f'Unsupported ELF class {elf_class}')
    machine = struct.unpack_from('<H' if elf_class == 1 else '<H', data, 18)[0]
    if machine != profile['machine']:
        raise ValueError(f"Expected {profile['name']} machine "
                         f"{profile['machine']}, found {machine}")
    if digest(data) != profile['input']:
        raise ValueError(
            f"Unexpected {profile['name']} libqtigef input; refusing to patch.\n"
            f"  expected {profile['input']}\n  actual   {digest(data)}")
    return profile


def patch(data):
    profile = check_elf(data)

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
    if digest(patched) != profile['output']:
        raise ValueError(
            'Patched output hash mismatch; the replacement changed more than '
            f"the platform literal.\n  expected {profile['output']}\n"
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
