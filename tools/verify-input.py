#!/usr/bin/env python3
"""Validate pinned stock inputs, original APK payloads and exact app-local API signatures."""
import argparse
import importlib.util
from pathlib import Path
import re
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zipfile
from functools import lru_cache
from artifact_record import verify
ROOT=Path(__file__).resolve().parents[1]
NS='http://schemas.android.com/apk/res/android'

def module(name,file):
 s=importlib.util.spec_from_file_location(name,file);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m

def class_index(directory):
 out={}
 for f in directory.rglob('*.smali'):
  text=f.read_text();match=re.search(r'^\.class (?:\S+ )*(L[^;\n]+;)$',text,re.M)
  if not match:continue
  name=match[1];assert name not in out,'Duplicate DEX class '+name
  methods=set(re.findall(r'^\.method (?:\S+ )*(\S+\([^\n]+)$',text,re.M))
  fields=set(re.findall(r'^\.field (?:\S+ )*(\S+:[^\s=]+)',text,re.M))
  out[name]=(text,methods|fields)
 return out

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--rom-root',required=True,type=Path);a=p.parse_args();rom=a.rom_root
 module('input_builder',ROOT/'tools/build-input.py').verify_sources()
 dex_tools=module('dex_tools',ROOT/'tools/patch-misound.py')
 pairs=[('input','product/app/MiuiInputSettings_MIUI15/MiuiInputSettings_MIUI15.apk','product/app/MiuiInputSettings/MiuiInputSettings.apk'),
 ('ota','system/system/app/BluetoothExtension/BluetoothExtension.apk','system_ext/priv-app/NabuStylusOta/NabuStylusOta.apk')]
 with tempfile.TemporaryDirectory(prefix='nabu-input-verify-') as tmp:
  w=Path(tmp);indexes={}
  for name,stock,ported in pairs:
   raw=ROOT/'proprietary'/stock;apk=ROOT/'proprietary/ported'/ported
   verify(ROOT,apk)
   subprocess.run([str(rom/'out/host/linux-x86/bin/apksigner'),'verify',str(apk)],check=True)
   subprocess.run([str(rom/'out/host/linux-x86/bin/zipalign'),'-c','-P','16','4',str(apk)],check=True,capture_output=True)
   with zipfile.ZipFile(raw) as z,zipfile.ZipFile(apk) as out:
    for entry in z.namelist():
     if entry.startswith(('res/','assets/','lib/')) or entry=='resources.arsc':assert z.read(entry)==out.read(entry),(name,entry)
    if name=='ota':assert z.read('classes.dex')==out.read('classes.dex'),'Original OTA code was altered'
    index={}
    for entry in out.namelist():
     if not re.fullmatch(r'classes\d*\.dex',entry):continue
     data=out.read(entry);assert not dex_tools.dex_strings_sorted(data)[1],(name,entry,'unsorted DEX')
     dex=w/(name+'-'+entry);dex.write_bytes(data);dest=w/(name+'-'+entry+'-smali')
     subprocess.run(['java','-jar',str(rom/'prebuilts/extract-tools/common/smali/baksmali.jar'),'d',str(dex),'-o',str(dest)],check=True,capture_output=True)
     extra=class_index(dest);assert not set(index)&set(extra),'Duplicate classes across DEX files';index.update(extra)
    indexes[name]=index
   tree=subprocess.check_output([str(rom/'out/host/linux-x86/bin/aapt2'),'dump','xmltree',str(apk),'--file','AndroidManifest.xml'],text=True)
   assert 'android.permission.STATUS_BAR_SERVICE' in tree if name=='input' else 'android.permission.BLUETOOTH_PRIVILEGED' in tree
   if name=='ota':
    assert 'android.uid.bluetooth' not in tree,'OTA companion must not join Bluetooth shared UID'
    assert tree.count('E: service ')==3, 'Unexpected exposed OTA components'
   print('PASS:',name,'APK signature/alignment, original payloads, DEX integrity and manifest boundaries')
  # Resolve the input app's MIUI references against its actual primary/secondary DEX,
  # including complete overload descriptors rather than checking method names alone.
  index=indexes['input'];refs=set()
  for text,_ in index.values():refs.update(re.findall(r'(L(?:miui/|org/pixelos/nabu/compat/)[^;]+;)->([^\s,]+)',text))
  @lru_cache(None)
  def boot_members(owner):
   name=owner[1:-1].replace('/','.')
   cp=str(rom/'out/soong/.intermediates/frameworks/base/framework/android_common/turbine-combined/framework.jar')+':'+str(rom/'prebuilts/sdk/current/public/android.jar')
   out=subprocess.check_output(['javap','-p','-s','-classpath',cp,name],text=True)
   members=set();previous=''
   for line in out.splitlines():
    stripped=line.strip()
    if stripped.startswith('descriptor: '):
     desc=stripped[len('descriptor: '):]
     if desc.startswith('('):
      method=re.search(r'([^\s(]+)\(',previous)
      if method:members.add(method[1]+desc)
     else:
      field=re.search(r'([^\s;]+);$',previous)
      if field:members.add(field[1]+':'+desc)
    elif stripped:previous=stripped
   # Only the class declaration describes its superclass. Method generic bounds
   # such as <T extends View> must never be interpreted as inheritance.
   parent=re.search(r'\bclass [\w.$]+(?:<[^{}]*>)? extends ([\w.$]+)',out.split('{',1)[0])
   if parent:members.update(boot_members('L'+parent[1].replace('.','/')+';'))
   return members
  def resolves(owner,member,seen=None):
   if owner not in index:return member in boot_members(owner)
   text,members=index[owner]
   if member in members:return True
   parent=re.search(r'^\.super (L[^;]+;)',text,re.M)
   return bool(parent) and resolves(parent[1],member)
  for owner,member in sorted(refs):
   assert owner in index and resolves(owner,member), 'Unresolved input API '+owner+'->'+member
  alltext='\n'.join(text for text,_ in index.values())
  assert 'Landroid/provider/MiuiSettings$' not in alltext
  assert 'Landroid/view/KeyboardShortcutInfo;' not in alltext
  assert not re.search(r'invoke-\S+ \{[^\n]+ Landroid/content/Intent;->getMiuiFlags',alltext)
  print('PASS: %d exact input API member references, no MIUI boot Settings/ShortcutInfo/Intent calls'%len(refs))
  ota=indexes['ota'];required=[
   ('Lmiui/util/ITouchFeature;','setTouchMode(III)Z'),('Lmiui/os/Build;','getRegion()Ljava/lang/String;'),
   ('Lmiui/util/FeatureParser;','getString(Ljava/lang/String;)Ljava/lang/String;')]
  for owner,member in required:assert owner in ota and member in ota[owner][1],owner+'->'+member
  print('PASS: original OTA services and TouchFeature API adapter are present')
 print('These are host checks, not proof of on-device OTA, USB reports, Bluetooth/GATT or framework runtime behavior.')
if __name__=='__main__':main()
