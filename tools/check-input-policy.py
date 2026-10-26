from pathlib import Path
import re,subprocess,argparse,tempfile
parser=argparse.ArgumentParser(description='Current-source combined policy smoke check; not a partitioned policy build')
parser.add_argument('--android-root',required=True,type=Path)
parser.add_argument('--build-variant',choices=['user','userdebug','eng'],default='user')
parser.add_argument('--output-dir',type=Path,help='Retain combined reference policy for inspection')
a=parser.parse_args()
v=Path(__file__).resolve().parents[1];root=a.android_root;src=root/'system/sepolicy'
temporary=None if a.output_dir else tempfile.TemporaryDirectory(prefix='nabu-policy-')
w=a.output_dir.resolve() if a.output_dir else Path(temporary.name)
w.mkdir(parents=True,exist_ok=True)
p=root/'out/soong/.intermediates/system/sepolicy/sepolicy_neverallows.checkpolicy.conf/android_common/sepolicy_neverallows.checkpolicy.conf'
t=p.read_text();parts=re.split(r'(?=^#line \d+ "[^"]+")',t,flags=re.M);removed=[];out=[]
for part in parts:
 m=re.match(r'#line \d+ "([^"]+)"',part)
 if m and m[1].startswith('vendor/xiaomi/dolby-renoir/'):
  removed.append(m[1])
 else:out.append(part)
t=''.join(out)
# The cached reference product is renoir. Import the exact QCOM legacy type
# used by sm8150's existing battery labels, rather than inventing a label/type.
extra_types=''
if not re.search(r'^type sysfs_battery_supply[,;]',t,re.M):
 legacy=root/'device/qcom/sepolicy_vndr/legacy-um/legacy/vendor/common/file.te'
 declaration=re.search(r'^type sysfs_battery_supply[^;]+;',legacy.read_text(),re.M)
 if not declaration:raise SystemExit('Missing target QCOM legacy battery type')
 extra_types=declaration[0]+'\n'
 print('Reference check adds target QCOM legacy declaration:',legacy)
assert len(removed)==5 and 'hal_dolby_dms' not in t,removed
files=[src/'public/global_macros',src/'public/neverallow_macros',src/'private/mls_macros',src/'public/te_macros',v/'sepolicy/public/attributes',v/'input/sepolicy/public/attributes']+sorted((v/'sepolicy/vendor').glob('*.te'))+sorted((v/'input/sepolicy/private').glob('*.te'))+sorted((v/'input/sepolicy/vendor').glob('*.te'))
r=subprocess.run(['m4','-Dtarget_full_treble=true','-Dtarget_build_variant='+a.build_variant]+[str(f) for f in files],capture_output=True,text=True,check=True)
attrs='\n'.join(l for l in r.stdout.splitlines() if l.startswith('attribute '))+'\n';rules=extra_types+'\n'.join(l for l in r.stdout.splitlines() if not l.startswith('attribute '))+'\n'
pos=re.search(r'^attribute\s',t,re.M).start();t=t[:pos]+attrs+t[pos:];pos=re.search(r'^role\s',t,re.M).start();t=t[:pos]+rules+t[pos:]
# Include actual genfs labels: policy compilation must catch type/path errors too.
for labels in sorted((v/'input/sepolicy/vendor').glob('genfs_contexts')):
 t+='\n'+labels.read_text()
p=w/'nabu-policy.conf';p.write_text(t)
r=subprocess.run([str(root/'out/host/linux-x86/bin/checkpolicy'),'-M','-c','30','-o',str(w/'nabu-policy'),str(p)],capture_output=True,text=True)
print(r.stdout,r.stderr); print('Current-source policy smoke check exit:',r.returncode)
if r.returncode == 0:
 for option,name in [('-p','property_contexts'),('-l','hwservice_contexts')]:
  subprocess.run([str(root/'out/host/linux-x86/bin/checkfc'),option,str(w/'nabu-policy'),str(v/'input/sepolicy/vendor'/name)],check=True)
 subprocess.run([str(root/'out/host/linux-x86/bin/property_info_checker'),str(w/'nabu-policy'),str(v/'input/sepolicy/vendor/property_contexts')],check=True)
 print('PASS: input property/hwservice contexts and typed property information')
 # Compilation does not establish that init's actual operations are permitted.
 # A deliberately inverse neverallow must fail on the exact required allow.
 analyzer=root/'out/host/linux-x86/bin/sepolicy-analyze'
 required=[
  ('vendor_init','vendor_sysfs_nabu_pen','file','setattr'),
  ('vendor_init','vendor_sysfs_nabu_keyboard','file','setattr'),
  ('vendor_init','vendor_sysfs_nabu_pen','file','write'),
  ('vendor_init','vendor_sysfs_nabu_keyboard','file','write'),
  ('hal_nabu_input_control_default','vendor_sysfs_nabu_pen','file','write'),
  ('hal_nabu_input_control_default','vendor_nabu_input_control_prop','property_service','set'),
  ('vendor_init','vendor_nabu_input_control_prop','property_service','set'),
  ('vendor_init','vendor_dolby_config_prop','property_service','set'),
  ('hal_audio_default','hal_dolby_dms_hwservice','hwservice_manager','find'),
 ]
 for source,target,kind,permission in required:
  assertion=f'neverallow {source} {target}:{kind} {permission};'
  probe=subprocess.run([str(analyzer),str(w/'nabu-policy'),'neverallow','-n',assertion],capture_output=True,text=True)
  if probe.returncode==0 or 'violated by allow' not in probe.stdout+probe.stderr:
   raise SystemExit('Missing required operation or failed permission query: '+assertion+'\n'+probe.stdout+probe.stderr)
 print('PASS: init sysfs chown/write, persisted property setters and audio HAL service lookup are allowed')
raise SystemExit(r.returncode)
