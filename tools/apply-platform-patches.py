#!/usr/bin/env python3
"""Check or apply the exact nabu input framework/Settings patches. Never overwrite changed source."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
ROOT=Path(__file__).resolve().parents[1]

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--android-root',required=True,type=Path);p.add_argument('--apply',action='store_true');a=p.parse_args()
 sources=json.loads((ROOT/'patches/source-inputs.json').read_text());pending=[]
 for repo,files in sources.items():
  tree=a.android_root/repo;patch=ROOT/'patches'/('frameworks-base.patch' if repo=='frameworks/base' else 'settings.patch')
  if subprocess.run(['git','-C',str(tree),'apply','--reverse','--check',str(patch)],capture_output=True).returncode==0:
   print('Already applied:',repo);continue
  for name,sha in files.items():
   f=tree/name
   if (sha is None and f.exists()) or (sha is not None and (not f.is_file() or hashlib.sha256(f.read_bytes()).hexdigest()!=sha)):
    raise SystemExit('Source changed, review/rebase patch first: '+str(f))
  subprocess.run(['git','-C',str(tree),'apply','--check',str(patch)],check=True)
  pending.append((tree,patch))
 # Check every repo before changing any repo; explicit --apply is required.
 for tree,patch in pending:
  if a.apply:subprocess.run(['git','-C',str(tree),'apply',str(patch)],check=True)
  print(('Applied: ' if a.apply else 'Ready: ')+str(tree))
if __name__=='__main__':main()
