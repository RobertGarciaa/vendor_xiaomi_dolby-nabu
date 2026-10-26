#!/usr/bin/env python3
"""Check stock pins, actual APK DEX/shim contracts, UUIDs and configuration."""
import argparse
import importlib.util
from pathlib import Path
import re
import struct
import subprocess
import tempfile
import uuid
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]

def effect_uuid(text):
    u = uuid.UUID(text)
    return struct.pack('<IHHH', u.time_low, u.time_mid, u.time_hi_version,
                       int.from_bytes(u.bytes[8:10], 'big')) + u.bytes[10:]

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--rom-root', required=True, type=Path)
    a = p.parse_args()
    subprocess.run(['python3', str(ROOT/'extract-files.py'), '--verify-only'], check=True)
    spec = importlib.util.spec_from_file_location('patch', ROOT/'tools/patch-misound.py')
    m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    apk = ROOT/'proprietary/ported/product/app/MiSound/MiSound.apk'
    subprocess.run([str(a.rom_root/'out/host/linux-x86/bin/apksigner'), 'verify', str(apk)], check=True)
    with zipfile.ZipFile(apk) as z:
        dex, shims = z.read('classes.dex'), z.read('classes2.dex')
    assert not m.dex_strings_sorted(dex)[1], 'DEX string_ids are unsorted'
    assert m.OLD_TYPE_UUID.encode() not in dex
    assert dex.count(m.NEW_TYPE_UUID.encode()) == 1
    assert dex.count(m.HW_IMPL_UUID.encode()) == 1
    for marker in [m.SELECTION_GUARD_MARKER, m.CREATE_GUARD_MARKER,
                   m.DESTROY_GUARD_MARKER, m.GEQ_GUARD_MARKER]:
        assert dex.count(marker.encode()) == 1, marker
    for abi in ['lib','lib64']:
        raw = (ROOT/'proprietary/vendor'/abi/'soundfx/libhwdap.so').read_bytes()
        assert effect_uuid(m.NEW_TYPE_UUID) + effect_uuid(m.HW_IMPL_UUID) in raw
    xml = ET.parse(ROOT/'configs/audio/audio_effects_dolby.xml').getroot()
    ns = {'x':xml.tag.split('}')[0][1:]}
    libraries = {e.attrib['name']:e.attrib['path'] for e in xml.find('x:libraries',ns)}
    assert libraries['dap'] == 'libhwdap.so'
    for effect in xml.find('x:effects',ns):
        assert effect.attrib['library'] in libraries
        for sub in effect:
            assert sub.attrib['library'] in libraries
    assert sum(e.attrib.get('name') == 'dap' for e in xml.find('x:effects',ns)) == 1
    with tempfile.TemporaryDirectory(prefix='nabu-apk-contract-') as td:
        d = Path(td)
        smali = a.rom_root/'prebuilts/extract-tools/common/smali/baksmali.jar'
        for name, data in [('app',dex),('shims',shims)]:
            f=d/(name+'.dex');f.write_bytes(data)
            subprocess.run(['java','-jar',str(smali),'d',str(f),'-o',str(d/name)],check=True,capture_output=True)
        provided = {}
        for f in (d/'shims').rglob('*.smali'):
            text=f.read_text();cls=re.search(r'^\.class .* (L[^;]+;)$',text,re.M)[1]
            methods=set(re.findall(r'^\.method .*? (\S+\([^\n]+)$',text,re.M))
            fields=set(re.findall(r'^\.field .*? (\S+:[^\s=]+)',text,re.M))
            provided[cls]=methods|fields
        refs=set()
        for f in (d/'app').rglob('*.smali'):
            refs.update(re.findall(r'(Lmiui/[^;]+;)->([^\s,]+)',f.read_text()))
        for cls,member in refs:
            assert cls in provided and member in provided[cls], 'Missing shim signature '+cls+'->'+member
        # Haptic methods also referenced through reflection by the pinned r3/a.
        haptic=(d/'app/r3/a.smali').read_text()
        for name in re.findall(r'const-string [vp]\d+, "((?:perform|isSupport|stop)[A-Za-z]*)"',haptic):
            assert any(x.startswith(name+'(') for x in provided['Lmiui/util/HapticFeedbackUtil;']), name
    print('PASS: APK signature, sorted DEX, nabu patches, both hardware DAP descriptors, exact MIUI member signatures and effects XML')

if __name__ == '__main__':
    main()
