"""Detect stale generated APKs without pretending that ZIP signing metadata is reproducible."""
import hashlib
import json
from pathlib import Path

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def record(root, apk, sources, framework):
    report={'apk_sha256':sha(apk),'platform_framework_sha256':sha(framework),
            'source_sha256':{str(p.relative_to(root)):sha(p) for p in sorted(set(sources+[Path(__file__).resolve()]))}}
    apk.with_suffix('.build.json').write_text(json.dumps(report,indent=2)+'\n')

def verify(root,apk):
    report=json.loads(apk.with_suffix('.build.json').read_text())
    if sha(apk)!=report['apk_sha256']:raise ValueError('Generated APK changed: '+str(apk))
    for rel,expected in report['source_sha256'].items():
        if sha(root/rel)!=expected:raise ValueError('Generated APK is stale; rebuild after changing '+rel)
