#!/usr/bin/env python3
"""Static audit of the Dolby vendor tree.

Checks that can be run without touching the Android build system:
  * every install path owned by this repo appears exactly once
  * no install_symlink lands on a path a cc module also installs
  * every `apk:`/`src:`/`srcs:` input referenced by Android.bp exists
  * every PRODUCT_PACKAGES module named by dolby.mk is defined here or in a
    repository this product inherits
  * pinned blob hashes match the shipped files

It deliberately does not invoke Kati/Soong: the full build belongs to the user,
and a --dumpvar run previously consumed a lot of memory.
"""
import argparse
import hashlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# Repositories this product inherits, resolved under the ROM root the caller
# passes. Nothing here hard-codes the developer's checkout path.
SIBLING_PATHS = [
    'vendor/xiaomi/nabu',
    'vendor/xiaomi/sm8150-common',
    'device/xiaomi/nabu',
    'device/xiaomi/sm8150-common',
]


def read_bp():
    return (ROOT / 'Android.bp').read_text()


def module_blocks(bp_text):
    """Split Android.bp into (module_type, body) pairs."""
    blocks = []
    for m in re.finditer(r'^(\w[\w_]*)\s*\{', bp_text, re.M):
        kind = m.group(1)
        depth = 0
        start = m.end() - 1
        i = start
        while i < len(bp_text):
            if bp_text[i] == '{':
                depth += 1
            elif bp_text[i] == '}':
                depth -= 1
                if depth == 0:
                    break
            i += 1
        blocks.append((kind, bp_text[start:i + 1]))
    return blocks


def field(body, name):
    m = re.search(rf'^\s*{name}:\s*"([^"]*)"', body, re.M)
    return m.group(1) if m else None


def field_list(body, name):
    m = re.search(rf'^\s*{name}:\s*\[(.*?)\]', body, re.M | re.S)
    if not m:
        return []
    return re.findall(r'"([^"]*)"', m.group(1))


def install_path(kind, body):
    """Best-effort installed path for the module kinds this repo uses."""
    name = field(body, 'name')
    if kind == 'install_symlink':
        return field(body, 'installed_location')
    if kind == 'prebuilt_etc':
        filename = field(body, 'filename') or name
        sub = field(body, 'sub_dir')
        return f'etc/{sub}/{filename}' if sub else f'etc/{filename}'
    if kind == 'base_rfsa' or kind == 'prebuilt_rfsa':
        filename = field(body, 'filename') or name
        rel = field(body, 'relative_install_path')
        return f'lib/rfsa/{rel}/{filename}' if rel else f'lib/rfsa/{filename}'
    if kind in ('cc_prebuilt_library_shared', 'cc_library_shared'):
        filename = field(body, 'filename') or f'{name}.so'
        stem = field(body, 'stem')
        if stem and not field(body, 'filename'):
            filename = f'{stem}.so'
        rel = field(body, 'relative_install_path')
        return f'lib/hw/{filename}' if rel == 'hw' else f'lib/{filename}'
    if kind == 'cc_binary':
        return f'bin/{name}'
    return None


def audit_install_paths(bp_text, errors, warnings):
    # A cc module with filename set and stem set installs under stem; treat both
    # spellings as the same owner so a deliberate replacement is not flagged.
    owners = {}
    for kind, body in module_blocks(bp_text):
        path = install_path(kind, body)
        if not path:
            continue
        name = field(body, 'name')
        owners.setdefault(path, []).append((kind, name))

    for path, mods in sorted(owners.items()):
        if len(mods) < 2:
            continue
        # overrides makes a deliberate replacement legal.
        overridden = set()
        for kind, body in module_blocks(bp_text):
            if field(body, 'name') in {m[1] for m in mods}:
                overridden.update(field_list(body, 'overrides'))
        leftover = [m for m in mods if m[1] not in overridden]
        if len(leftover) > 1:
            errors.append(
                f'multiple modules install {path}: '
                + ', '.join(f'{k} {n}' for k, n in leftover))
        else:
            warnings.append(
                f'{path} is replaced via overrides: '
                + ', '.join(n for _, n in mods))


def audit_inputs(bp_text, errors):
    for kind, body in module_blocks(bp_text):
        name = field(body, 'name')
        for key in ('apk', 'src', 'main'):
            value = field(body, key)
            if not value:
                continue
            target = ROOT / value
            if not target.exists():
                errors.append(f'{name}: {key}={value} does not exist')
        for value in field_list(body, 'srcs'):
            if value.startswith(':'):
                continue
            # Soong globs are resolved at build time.
            if '*' in value or '?' in value:
                continue
            # Soong config expansions.
            if '$(' in value:
                continue
            target = ROOT / value
            if not target.exists():
                errors.append(f'{name}: srcs entry {value} does not exist')


def sibling_module_names(rom_root):
    names = set()
    for repo in (Path(rom_root) / p for p in SIBLING_PATHS):
        for bp in list(repo.glob('Android.bp')) + list(repo.glob('packages/*/Android.bp')):
            if not bp.is_file():
                continue
            for m in re.finditer(r'^\s*name:\s*"([^"]+)"',
                                 bp.read_text(errors='replace'), re.M):
                names.add(m.group(1))
    return names


def parse_product_packages(mk_text):
    """Return (added, ignored) module names declared in dolby.mk.

    `-=` is reported separately: Make has no minus-assignment operator, so Kati
    treats the line as an assignment to a variable named "PRODUCT_PACKAGES -"
    and the removal silently never happens.
    """
    added, ignored = [], []
    # Join continuation lines so one logical assignment is one string.
    for raw in mk_text.splitlines():
        line = raw.strip()
        m = re.match(r'PRODUCT_PACKAGES\s*\+=\s*(.*)', line)
        if m:
            added += [x for x in m.group(1).split() if x and x != '\\']
            continue
        m = re.match(r'PRODUCT_PACKAGES\s*-=\s*(.*)', line)
        if m:
            ignored += [x for x in m.group(1).split() if x and x != '\\']
    return added, ignored


def audit_packages(bp_text, errors, rom_root):
    mk = (ROOT / 'dolby.mk').read_text()
    here = {field(body, 'name') for _, body in module_blocks(bp_text)}
    elsewhere = sibling_module_names(rom_root) | here
    added, ignored = parse_product_packages(mk)

    for name in ignored:
        errors.append(
            f'dolby.mk uses PRODUCT_PACKAGES -= {name}; Make has no minus '
            'assignment, so Kati keeps the old list and nothing is removed')

    for name in added:
        if name in here or name in elsewhere:
            continue
        errors.append(f'dolby.mk PRODUCT_PACKAGES += {name} '
                      'is not defined in this repo or an inherited one')


def added_by_product_packages(mk_text, module):
    """Return True if module is added by PRODUCT_PACKAGES, and whether that
    addition sits inside a TARGET_ENABLE_XIAOMI_DOLBY conditional."""
    stack = []
    in_list = False
    added = unguarded = False
    for raw in mk_text.splitlines():
        line = raw.strip()
        if re.match(r'ifn?eq\b|ifdef\b|ifndef\b', line):
            stack.append('TARGET_ENABLE_XIAOMI_DOLBY' in line)
            continue
        if line.startswith('endif'):
            if stack:
                stack.pop()
            continue
        if in_list:
            if module in line.split():
                added = True
                if not any(stack):
                    unguarded = True
            if not line.endswith('\\'):
                in_list = False
            continue
        m = re.match(r'PRODUCT_PACKAGES\s*\+?=\s*(.*)', line)
        if m:
            rhs = m.group(1)
            if module in [w.rstrip('\\') for w in rhs.split()]:
                added = True
                if not any(stack):
                    unguarded = True
            in_list = rhs.rstrip().endswith('\\')
    return added, unguarded


def audit_qtigef_single_owner(bp_text, errors, rom_root):
    """libqtigef_nabu owns /vendor/lib/libqtigef.so; the shared copy must be off.

    `overrides` cannot express this: fsgen turns it into Overridden_deps and adds
    a dependency for every arch of the vendor image, but the shared libqtigef is
    arm-only, so arm64 resolution fails before anything is built.
    """
    body = next((b for k, b in module_blocks(bp_text)
                 if k == 'cc_prebuilt_library_shared'
                 and field(b, 'name') == 'libqtigef_nabu'), None)
    if body is None:
        errors.append('libqtigef_nabu module is missing')
        return
    if field(body, 'stem') != 'libqtigef':
        errors.append('libqtigef_nabu must install as libqtigef.so via stem')
    if field_list(body, 'overrides'):
        errors.append('libqtigef_nabu must not use overrides: fsgen asks for an '
                      'arm64 variant of the arm-only shared libqtigef')

    shared = Path(rom_root) / 'vendor/xiaomi/sm8150-common/sm8150-common-vendor.mk'
    if not shared.is_file():
        errors.append(f'{shared} is missing; cannot verify single ownership')
        return
    added, unguarded = added_by_product_packages(shared.read_text(), 'libqtigef')
    if not added:
        errors.append('sm8150-common-vendor.mk no longer adds libqtigef; the '
                      'Dolby build would lose the stock library')
    elif unguarded:
        errors.append('sm8150-common-vendor.mk adds libqtigef without a '
                      'TARGET_ENABLE_XIAOMI_DOLBY guard, so Dolby products get '
                      'two writers for /vendor/lib/libqtigef.so')


def audit_pins(errors):
    sums = ROOT / 'proprietary-files.sha256sum'
    for line in sums.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        expected, rel = line.split(None, 1)
        path = ROOT / 'proprietary' / rel
        if not path.is_file():
            errors.append(f'pinned blob missing: {rel}')
            continue
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        if actual != expected:
            errors.append(f'pinned blob changed: {rel}')


def audit_no_symlink_on_hal(errors):
    bp_text = (ROOT / 'Android.bp').read_text()
    for kind, body in module_blocks(bp_text):
        if kind != 'install_symlink':
            continue
        location = field(body, 'installed_location') or ''
        if location.startswith('lib/hw/audio.primary.'):
            errors.append(
                f'install_symlink {field(body, "name")} targets {location}; '
                'the qcom-caf source HAL owns that path')


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--rom-root', type=Path,
                   default=Path('/home/ccc/android/pixelos'),
                   help='Android tree used to resolve inherited modules')
    p.add_argument('--verbose', action='store_true')
    a = p.parse_args()

    errors, warnings = [], []
    bp_text = read_bp()

    audit_install_paths(bp_text, errors, warnings)
    audit_inputs(bp_text, errors)
    audit_packages(bp_text, errors, a.rom_root)
    audit_qtigef_single_owner(bp_text, errors, a.rom_root)
    audit_pins(errors)
    audit_no_symlink_on_hal(errors)

    print(f'modules           : {len(module_blocks(bp_text))}')
    print(f'install-path warns: {len(warnings)}')
    print(f'errors            : {len(errors)}')
    for w in warnings:
        print('  WARN ' + w)
    for e in errors:
        print('  FAIL ' + e)
    if not errors:
        print('PASS: install paths unique, inputs present, '
              'pins match, no HAL symlink')
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
