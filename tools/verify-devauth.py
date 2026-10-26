#!/usr/bin/env python3
"""Validate the optional reference APK; does not establish TEE or authentication runtime."""
import argparse
from collections import Counter
from pathlib import Path
import re
import subprocess
import tempfile
import zipfile
from artifact_record import verify

ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--rom-root', required=True, type=Path)
a = p.parse_args()
rom = a.rom_root.resolve()
tools = rom / 'out/host/linux-x86/bin'
raw = ROOT / 'proprietary/product/app/MiDevAuthService/MiDevAuthService.apk'
apk = ROOT / 'proprietary/ported/system_ext/priv-app/NabuMiDevAuth/NabuMiDevAuth.apk'
subprocess.run(['python3', str(ROOT / 'extract-files.py'), '--verify-only', '--group', 'usb-auth'], check=True)
verify(ROOT, apk)
subprocess.run([str(tools / 'apksigner'), 'verify', str(apk)], check=True)
subprocess.run([str(tools / 'zipalign'), '-c', '-P', '16', '4', str(apk)], check=True, capture_output=True)
with tempfile.TemporaryDirectory(prefix='nabu-devauth-verify-') as tmp:
    work = Path(tmp)
    with zipfile.ZipFile(raw) as original, zipfile.ZipFile(apk) as ported:
        for name in original.namelist():
            if name.startswith(('res/', 'assets/', 'lib/')) or name == 'resources.arsc':
                assert original.read(name) == ported.read(name), name
        for tag, source in [('original', original), ('ported', ported)]:
            dex = work / (tag + '.dex')
            dex.write_bytes(source.read('classes.dex'))
            subprocess.run(['java', '-jar', str(rom / 'prebuilts/extract-tools/common/smali/baksmali.jar'),
                            'd', str(dex), '-o', str(work / tag)], check=True, capture_output=True)
    def index(directory):
        return {str(f.relative_to(directory)): f.read_text() for f in directory.rglob('*.smali')}
    original, ported = index(work / 'original'), index(work / 'ported')
    assert original.keys() == ported.keys(), 'Class set changed'
    logging = broadcasts = changed = 0
    hidl = Counter()
    def defaults(text):
        # Smali omits trailing explicit encoded false/null static initializers on reassembly.
        text = re.sub(r'(?m)^(\.field [^\n]+:Z) = false$', r'\1', text)
        text = re.sub(r'(?m)^(\.field [^\n]+:(?:L[^;\n]+;|\[[^\n ]+)) = null$', r'\1', text)
        return '\n'.join(line for line in text.splitlines() if line.strip())
    for name, text in original.items():
        new = ported[name]
        if not name.startswith('com/xiaomi/devauth/'):
            assert defaults(text) == defaults(new), 'Unexpected non-auth code change: ' + name
            continue
        changed += text != new
        invokes = r'(?m)^    invoke-[^\n]+'
        def relevant(line):
            return not re.search(r'Landroid/util/Log;->(?:[vdiew]|wtf)\(', line) and \
                'Lcom/xiaomi/devauth/MiDevAuthService;->sendOrderedBroadcast(' not in line
        before, after = re.findall(invokes, text), re.findall(invokes, new)
        assert [x for x in before if relevant(x)] == [x for x in after if relevant(x)], name
        logging += sum(bool(re.search(r'Landroid/util/Log;->(?:[vdiew]|wtf)\(', x)) for x in before)
        broadcasts += sum('->sendOrderedBroadcast(' in x for x in before)
        assert all(relevant(x) for x in after), 'Diagnostic emission remains: ' + name
        for target in re.findall(r'Lvendor/xiaomi/[^\n]+', text):
            hidl[target] += 1
        assert re.findall(r'Lvendor/xiaomi/[^\n]+', text) == re.findall(r'Lvendor/xiaomi/[^\n]+', new)
    assert logging == 128 and broadcasts == 2 and changed > 0
    all_text = '\n'.join(ported.values())
    for marker in ['devauth_challenge_get', 'devauth_token_verify', 'devauth_BlackUid_check', 'clause_agreed', 'getFid']:
        assert marker in all_text, marker
    assert hidl, 'Native authentication references disappeared'
    tree = subprocess.check_output([str(tools / 'aapt2'), 'dump', 'xmltree', str(apk), '--file',
                                    'AndroidManifest.xml'], text=True)
    assert 'android.uid.system' in tree and 'android.permission.MANAGE_USB' in tree
    assert 'android.permission.BIND_JOB_SERVICE' in tree
    assert 'protectionLevel(0x01010009)=0x00000002' in tree or 'protectionLevel(0x01010009)=0x2' in tree
    assert tree.count('E: service ') == 2
    print('PASS: stock payloads, signature/alignment, freshness, unchanged non-auth classes and retained native/blacklist calls')
    print('PASS: 128 app Log calls and 2 diagnostic emissions removed; service binding restricted; job permission retained')
