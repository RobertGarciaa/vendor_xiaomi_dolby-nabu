#!/usr/bin/env python3
"""Run the hardware-control backend tests without a device or Android libraries."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
ROOT = Path(__file__).resolve().parents[1]
compiler = shutil.which('clang++')
if not compiler:
    raise SystemExit('clang++ is required')
with tempfile.TemporaryDirectory(prefix='nabu-control-check-') as directory:
    binary = Path(directory) / 'control-test'
    subprocess.run([compiler, '-std=c++17', '-Wall', '-Wextra', '-Werror',
                    '-fsanitize=address,undefined',
                    str(ROOT / 'input/control/Control.cpp'),
                    str(ROOT / 'input/control/tests/ControlTest.cpp'),
                    '-o', str(binary)], check=True)
    env = dict(os.environ)
    # LSan cannot inspect processes in the Codex ptrace sandbox. ASan/UBSan stay on.
    env['ASAN_OPTIONS'] = 'detect_leaks=0'
    subprocess.run([str(binary)], env=env, check=True)
print('PASS: control persistence/rollback, missing nodes, invalid requests and measurement handling (ASan/UBSan)')
