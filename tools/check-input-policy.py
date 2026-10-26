from pathlib import Path
import re,subprocess,argparse,tempfile
parser=argparse.ArgumentParser(description='Current-source combined policy smoke check; not a partitioned policy build')
parser.add_argument('--android-root',required=True,type=Path)
parser.add_argument('--build-variant',choices=['user','userdebug','eng'],default='user')
a=parser.parse_args()
v=Path(__file__).resolve().parents[1];root=a.android_root;src=root/'system/sepolicy'
temporary=tempfile.TemporaryDirectory(prefix='nabu-policy-');w=Path(temporary.name)
p=root/'out/soong/.intermediates/system/sepolicy/sepolicy_neverallows.checkpolicy.conf/android_common/sepolicy_neverallows.checkpolicy.conf'
t=p.read_text();parts=re.split(r'(?=^#line \d+ "[^"]+")',t,flags=re.M);removed=[];out=[]
for part in parts:
 m=re.match(r'#line \d+ "([^"]+)"',part)
 if m and m[1].startswith('vendor/xiaomi/dolby-renoir/'):
  removed.append(m[1])
 else:out.append(part)
t=''.join(out)
assert len(removed)==5 and 'hal_dolby_dms' not in t,removed
files=[src/'public/global_macros',src/'public/neverallow_macros',src/'private/mls_macros',src/'public/te_macros',v/'sepolicy/public/attributes',v/'input/sepolicy/public/attributes']+sorted((v/'sepolicy/vendor').glob('*.te'))+sorted((v/'input/sepolicy/private').glob('*.te'))+sorted((v/'input/sepolicy/vendor').glob('*.te'))
r=subprocess.run(['m4','-Dtarget_full_treble=true','-Dtarget_build_variant='+a.build_variant]+[str(f) for f in files],capture_output=True,text=True,check=True)
attrs='\n'.join(l for l in r.stdout.splitlines() if l.startswith('attribute '))+'\n';rules='\n'.join(l for l in r.stdout.splitlines() if not l.startswith('attribute '))+'\n'
pos=re.search(r'^attribute\s',t,re.M).start();t=t[:pos]+attrs+t[pos:];pos=re.search(r'^role\s',t,re.M).start();t=t[:pos]+rules+t[pos:]
# Include actual genfs labels: policy compilation must catch type/path errors too.
for labels in sorted((v/'input/sepolicy/vendor').glob('genfs_contexts')):
 t+='\n'+labels.read_text()
p=w/'nabu-policy.conf';p.write_text(t)
r=subprocess.run([str(root/'out/host/linux-x86/bin/checkpolicy'),'-M','-c','30','-o',str(w/'nabu-policy'),str(p)],capture_output=True,text=True)
print(r.stdout,r.stderr); print('Current-source policy smoke check exit:',r.returncode)
raise SystemExit(r.returncode)
