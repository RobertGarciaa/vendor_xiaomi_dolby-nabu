#!/usr/bin/env python3
"""Check the actual nabu combined policy; never substitute another device's policy.

Build sepolicy_neverallows for custom_nabu first. This checks the generated
combined policy and selected access requirements; partitioned CIL, mapping,
full contexts and final VINTF checks still belong to the product build.
"""
import argparse
import re
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--android-root', required=True, type=Path)
    p.add_argument('--out-dir', type=Path, help='Android OUT_DIR; defaults to <android-root>/out')
    p.add_argument('--output-dir', type=Path, help='retain compiled smoke-check policy here')
    a = p.parse_args()
    out = a.out_dir or a.android_root / 'out'
    source = out / 'soong/.intermediates/system/sepolicy/sepolicy_neverallows.checkpolicy.conf/android_common/sepolicy_neverallows.checkpolicy.conf'
    if not source.is_file():
        raise SystemExit('Actual nabu combined policy missing. Build sepolicy_neverallows for custom_nabu first: ' + str(source))
    text = source.read_text()
    for marker in ('type hal_nabu_input_control_default,', 'type hal_dolby_dms_default,',
                   'type vendor_sysfs_nabu_pen,', 'type nabu_stylus_ota_app,'):
        if marker not in text:
            raise SystemExit('Policy lacks current nabu integration; rebuild nabu policy after source changes: ' + marker)
    # Source type names can be rewritten by the product's policy preprocessing.
    # Read the compiled IDT genfs labels instead of guessing the battery type.
    battery_types = set(re.findall(
        r'^genfscon\s+sysfs\s+\S+/power_supply/idt\s+u:object_r:([^:]+):s0',
        text, re.M))
    if not battery_types:
        raise SystemExit('Current nabu policy has no IDT power-supply genfs label')
    tools = out / 'host/linux-x86/bin'
    for name in ('checkpolicy', 'checkfc', 'property_info_checker', 'sepolicy-analyze'):
        if not (tools / name).is_file():
            raise SystemExit('Build the required host tool first: ' + str(tools / name))
    with tempfile.TemporaryDirectory(prefix='nabu-policy-') as temp:
        work = a.output_dir or Path(temp)
        work.mkdir(parents=True, exist_ok=True)
        conf = work / 'nabu-policy.conf'
        shutil.copyfile(source, conf)
        policy = work / 'nabu-policy'
        subprocess.run([str(tools/'checkpolicy'), '-M', '-c', '30', '-o', str(policy), str(conf)], check=True)
        for directory in ('sepolicy/vendor', 'input/sepolicy/vendor'):
            for option, filename in (('-p', 'property_contexts'), ('-l', 'hwservice_contexts')):
                subprocess.run([str(tools/'checkfc'), option, str(policy), str(ROOT/directory/filename)], check=True)
            subprocess.run([str(tools/'property_info_checker'), str(policy), str(ROOT/directory/'property_contexts')], check=True)
        required = [
            ('system_server', 'hal_nabu_input_control_hwservice', 'hwservice_manager', 'find'),
            ('system_server', 'hal_nabu_input_control_default', 'binder', 'call'),
            ('vendor_init', 'vendor_sysfs_nabu_pen', 'file', 'setattr'),
            ('vendor_init', 'vendor_sysfs_nabu_keyboard', 'file', 'setattr'),
            ('vendor_init', 'vendor_sysfs_nabu_pen', 'file', 'write'),
            ('vendor_init', 'vendor_sysfs_nabu_keyboard', 'file', 'write'),
            ('hal_nabu_input_control_default', 'vendor_sysfs_nabu_pen', 'file', 'write'),
            ('hal_nabu_input_control_default', 'vendor_nabu_input_control_prop', 'property_service', 'set'),
            ('vendor_init', 'vendor_nabu_input_control_prop', 'property_service', 'set'),
            ('vendor_init', 'vendor_dolby_config_prop', 'property_service', 'set'),
            ('hal_audio_default', 'hal_dolby_dms_hwservice', 'hwservice_manager', 'find'),
        ]
        required.extend(('hal_nabu_input_control_default', battery_type, 'file', permission)
                        for battery_type in sorted(battery_types)
                        for permission in ('open', 'read', 'getattr'))
        required.extend(('nabu_stylus_ota_app', 'nabu_stylus_ota_app',
                         'netlink_kobject_uevent_socket', permission)
                        for permission in ('create', 'bind', 'read', 'getattr', 'getopt', 'setopt'))
        for source_type, target, kind, permission in required:
            assertion = f'neverallow {source_type} {target}:{kind} {permission};'
            probe = subprocess.run([str(tools/'sepolicy-analyze'), str(policy), 'neverallow', '-n', assertion], capture_output=True, text=True)
            if probe.returncode == 0 or 'violated by allow' not in probe.stdout + probe.stderr:
                raise SystemExit('Missing required access or failed query: ' + assertion + '\n' + probe.stdout + probe.stderr)
    print('PASS: actual nabu combined policy, typed contexts and required init/HAL permissions')
    print('This does not replace the partitioned policy and final image checks.')

if __name__ == '__main__':
    main()
