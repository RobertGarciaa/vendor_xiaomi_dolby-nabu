#!/usr/bin/env python3
"""Regression checks: product filtering alone must not pass the GEF audit."""
import argparse
import importlib.util
import tempfile
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--rom-root', type=Path, required=True)
args = parser.parse_args()
repo = Path(__file__).resolve().parents[1]
stage = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('audit', stage / 'audit-tree.py')
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)
fixed_bp = (args.rom_root / 'vendor/xiaomi/sm8150-common/Android.bp').read_text()
original_gate = '    enabled: select(soong_config_variable("nabu_dolby", "replace_qtigef"), {\n        true: false,\n        default: true,\n    }),\n'
assert original_gate in fixed_bp
stock_bp = fixed_bp.replace(original_gate, '', 1)
dolby_bp = (repo / 'Android.bp').read_text()
with tempfile.TemporaryDirectory(prefix='nabu-gef-audit-') as tmp:
    root = Path(tmp)
    common = root / 'vendor/xiaomi/sm8150-common'
    common.mkdir(parents=True)
    (common / 'sm8150-common-vendor.mk').write_text((args.rom_root / 'vendor/xiaomi/sm8150-common/sm8150-common-vendor.mk').read_text())
    audit.ROOT = repo
    (common / 'Android.bp').write_text(fixed_bp)
    errors = []
    audit.audit_qtigef_single_owner(dolby_bp, errors, root)
    assert not errors, errors
    # This is the exact previously accepted configuration that Kati rejects.
    (common / 'Android.bp').write_text(stock_bp)
    errors = []
    audit.audit_qtigef_single_owner(dolby_bp, errors, root)
    assert any('PRODUCT_PACKAGES filtering alone' in e for e in errors), errors
    (common / 'Android.bp').write_text(fixed_bp)
    gate = '    enabled: select(soong_config_variable("nabu_dolby", "replace_qtigef"), {\n        true: true,\n        default: false,\n    }),\n'
    assert gate in dolby_bp
    errors = []
    audit.audit_qtigef_single_owner(dolby_bp.replace(gate, ''), errors, root)
    assert any('enabled only' in e for e in errors), errors
print('PASS GEF audit: valid gates accepted; old product-only workaround and unguarded replacement rejected')
