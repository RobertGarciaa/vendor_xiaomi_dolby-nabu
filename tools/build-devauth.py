#!/usr/bin/env python3
"""Prepare a hardened stock MiDevAuth reference APK without enabling the native chain."""
import argparse
import importlib.util
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zipfile
from artifact_record import record

ROOT = Path(__file__).resolve().parents[1]
NS = 'http://schemas.android.com/apk/res/android'
RAW = 'product/app/MiDevAuthService/MiDevAuthService.apk'

def run(*args):
    subprocess.run([str(x) for x in args], check=True)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--rom-root', required=True, type=Path)
    args = parser.parse_args()
    rom = args.rom_root.resolve()
    tools = rom / 'out/host/linux-x86/bin'
    jars = rom / 'prebuilts/extract-tools/common/smali'
    raw = ROOT / 'proprietary' / RAW
    run('python3', ROOT / 'extract-files.py', '--verify-only', '--group', 'usb-auth')
    run('python3', ROOT / 'extract-files.py', '--verify-only', '--group', 'input')
    spec = importlib.util.spec_from_file_location('dex_tools', ROOT / 'tools/patch-misound.py')
    dex_tools = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(dex_tools)
    with tempfile.TemporaryDirectory(prefix='nabu-devauth-') as tmp:
        work = Path(tmp)
        with zipfile.ZipFile(raw) as z:
            assert [n for n in z.namelist() if re.fullmatch(r'classes\d*\.dex', n)] == ['classes.dex']
            (work / 'classes.dex').write_bytes(z.read('classes.dex'))
        smali = work / 'smali'
        run('java', '-jar', jars / 'baksmali.jar', 'd', work / 'classes.dex', '-o', smali)
        logs = broadcasts = 0
        for file in (smali / 'com/xiaomi/devauth').rglob('*.smali'):
            text = file.read_text()
            # Remove only Log calls, leaving all key selection/verification/network logic intact.
            log = r'(?m)^    invoke-static(?:/range)? \{[^\n]+\}, Landroid/util/Log;->(?:[vdiew]|wtf)\([^\n]+\)I\n(?:\n    move-result ([vp]\d+)\n)?'
            def silence(match):
                return '    const/16 ' + match[1] + ', 0x0\n' if match[1] else ''
            text, count = re.subn(log, silence, text)
            logs += count
            # Original blacklist/token paths send UID/key diagnostics through ordered broadcasts.
            # Remove the emission, never the authentication call or its result handling.
            emission = r'(?m)^    invoke-virtual(?:/range)? \{[^\n]+\}, Lcom/xiaomi/devauth/MiDevAuthService;->sendOrderedBroadcast\(Landroid/content/Intent;Ljava/lang/String;\)V\n'
            text, count = re.subn(emission, '', text)
            broadcasts += count
            file.write_text(text)
        assert logs == 128 and broadcasts == 2, (logs, broadcasts)
        fixed = work / 'fixed.dex'
        run('java', '-jar', jars / 'smali.jar', 'a', smali, '-o', fixed)
        assert not dex_tools.dex_strings_sorted(fixed.read_bytes())[1]
        decoded = work / 'decoded'
        frames = work / 'framework'
        frames.mkdir()
        stock_framework = ROOT / 'proprietary/system/system/framework/framework-res.apk'
        run('apktool', 'if', '-p', frames, stock_framework)
        run('apktool', 'd', '-f', '-s', '-p', frames, '-o', decoded, raw)
        manifest = decoded / 'AndroidManifest.xml'
        tree = ET.parse(manifest)
        root = tree.getroot()
        ET.register_namespace('android', NS)
        app = root.find('application')
        service = [s for s in app.findall('service')
                   if s.get(f'{{{NS}}}name') == 'com.xiaomi.devauth.MiDevAuthService']
        assert len(service) == 1
        service[0].set(f'{{{NS}}}permission', 'android.permission.MANAGE_USB')
        permission = [p for p in root.findall('permission')
                      if p.get(f'{{{NS}}}name') == 'com.xiaomi.devauth.send.permission']
        assert len(permission) == 1
        permission[0].set(f'{{{NS}}}protectionLevel', 'signature')
        tree.write(manifest, encoding='utf-8', xml_declaration=True)
        run('apktool', 'b', '-p', frames, '-o', work / 'manifest.apk', decoded)
        with zipfile.ZipFile(work / 'manifest.apk') as z:
            compiled = z.read('AndroidManifest.xml')
        with zipfile.ZipFile(raw) as zin, zipfile.ZipFile(work / 'unsigned.apk', 'w') as zout:
            for entry in zin.infolist():
                if entry.filename.startswith('META-INF/') and entry.filename.upper().endswith(
                        ('.RSA', '.DSA', '.EC', '.SF', 'MANIFEST.MF')):
                    continue
                data = fixed.read_bytes() if entry.filename == 'classes.dex' else compiled \
                    if entry.filename == 'AndroidManifest.xml' else zin.read(entry.filename)
                zout.writestr(entry, data)
        output = ROOT / 'proprietary/ported/system_ext/priv-app/NabuMiDevAuth/NabuMiDevAuth.apk'
        output.parent.mkdir(parents=True, exist_ok=True)
        run(tools / 'zipalign', '-f', '-P', '16', '4', work / 'unsigned.apk', work / 'aligned.apk')
        key = rom / 'build/make/target/product/security'
        run(tools / 'apksigner', 'sign', '--key', key / 'platform.pk8', '--cert', key / 'platform.x509.pem',
            '--out', work / 'signed.apk', work / 'aligned.apk')
        run(tools / 'apksigner', 'verify', work / 'signed.apk')
        shutil.copy2(work / 'signed.apk', output)
        framework = rom / 'out/soong/.intermediates/frameworks/base/framework/android_common/turbine-combined/framework.jar'
        record(ROOT, output, [Path(__file__).resolve(), ROOT / 'tools/patch-misound.py',
                             ROOT / 'proprietary-usb-auth.sha256sum',
                             ROOT / 'proprietary-input.sha256sum', stock_framework, raw], framework)
        print(f'Built reference APK: removed {logs} app Log calls and {broadcasts} diagnostic broadcast')
        print('Not enabled: native MTD/midevauth/TEE service chain and actual USB topology remain unverified')

if __name__ == '__main__':
    main()
