#!/usr/bin/env python3
"""Check synthetic stock keyboard authentication framing and compile real Android adapters."""
import argparse
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--android-root', type=Path)
a = p.parse_args()
src = ROOT / 'input/usb/src'
test = ROOT / 'input/usb/tests'
javac, java = shutil.which('javac'), shutil.which('java')
if not javac or not java:
    raise SystemExit('javac and java are required')
with tempfile.TemporaryDirectory(prefix='nabu-usb-auth-') as tmp:
    out = Path(tmp)
    common = [javac, '-source', '17', '-target', '17', '-Xlint:all,-options', '-Werror']
    subprocess.run(common + ['-d', str(out), str(src / 'org/pixelos/nabu/usb/KeyboardAuth.java'),
                            *map(str, sorted(test.rglob('*.java')))], check=True)
    subprocess.run([java, '-ea', '-cp', str(out), 'org.pixelos.nabu.usb.KeyboardAuthTest'], check=True)
    if a.android_root:
        rom = a.android_root.resolve()
        framework = rom / 'out/soong/.intermediates/frameworks/base/framework/android_common/turbine-combined/framework.jar'
        android = rom / 'prebuilts/sdk/current/public/android.jar'
        subprocess.run(common + ['-classpath', str(framework) + ':' + str(android), '-d', str(out),
                                *map(str, sorted(src.rglob('*.java')))], check=True)
        dex = out / 'dex'
        dex.mkdir()
        subprocess.run([str(rom / 'out/host/linux-x86/bin/d8'), '--min-api', '33', '--lib', str(android),
                        '--output', str(dex), *map(str, sorted(out.rglob('*.class')))], check=True)
        print('PASS: Android USB and stock Binder adapters compile against current platform headers and D8')
    else:
        print('Android adapter compilation skipped; provide --android-root for platform compile check')
