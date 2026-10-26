#!/usr/bin/env python3
"""Extract nabu Dolby source blobs, checking every byte against pinned hashes."""
import argparse
import hashlib
import importlib.util
from pathlib import Path
import shutil
import tempfile

ROOT = Path(__file__).resolve().parent

def digest(data):
    return hashlib.sha256(data).hexdigest()

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('dump', nargs='?', type=Path)
    p.add_argument('--verify-only', action='store_true')
    p.add_argument('--group', choices=['atmos','input','all'], default='atmos')
    a = p.parse_args()
    if not a.verify_only and not a.dump:
        p.error('specify a stock nabu dump or --verify-only')
    records = {}
    for group in groups:
        sums = ROOT / ('proprietary-files.sha256sum' if group == 'atmos' else 'proprietary-' + group + '.sha256sum')
        for line in sums.read_text().splitlines():
            if not line or line.startswith('#'): continue
            sha, rel = line.split(None, 1)
            if rel in records and records[rel] != sha: raise SystemExit('Conflicting source pin: ' + rel)
            records[rel] = sha
    entries = [(sha, rel) for rel, sha in records.items()]
    if a.verify_only:
        for expected, rel in entries:
            f = ROOT / 'proprietary' / rel
            if not f.is_file() or digest(f.read_bytes()) != expected:
                raise SystemExit('Missing or changed source blob: ' + rel)
    else:
        spec = importlib.util.spec_from_file_location('compat', ROOT / 'tools/dms_foundation_compat.py')
        m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
        with tempfile.TemporaryDirectory(prefix='nabu-extract-') as tmp:
            stage = Path(tmp)
            for expected, rel in entries:
                data = (m.extract(a.dump, shutil.which('debugfs')) if rel.startswith('compat/') else (a.dump / rel).read_bytes())
                if digest(data) != expected:
                    raise SystemExit('Wrong stock firmware or damaged file: ' + rel)
                dest = stage / rel; dest.parent.mkdir(parents=True, exist_ok=True); dest.write_bytes(data)
            # Do not replace any existing input until all hashes have passed.
            for _, rel in entries:
                dest = ROOT / 'proprietary' / rel; dest.parent.mkdir(parents=True, exist_ok=True); shutil.copy2(stage / rel, dest)
    print('PASS: %d pinned nabu source files' % len(entries))

if __name__ == '__main__':
    main()
