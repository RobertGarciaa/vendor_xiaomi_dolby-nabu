#!/usr/bin/env python3
"""Repackage only original nabu stylus/keyboard OTA services; do not replace the Bluetooth stack."""
import argparse
import importlib.util
from pathlib import Path
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zipfile
from artifact_record import record

ROOT=Path(__file__).resolve().parents[1]
NS='http://schemas.android.com/apk/res/android'
SERVICES={
 'com.android.bluetooth.ble.app.mipencil.ota.StylusOtaService',
 'com.android.bluetooth.ble.app.oobhelper.MiuiBleOobHelperService',
 'com.android.bluetooth.ble.app.oobhelper.MiuiKeyboardOobService',
}
def run(*args):subprocess.run([str(x) for x in args],check=True)
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--rom-root',required=True,type=Path);p.add_argument('--keep-work',type=Path);a=p.parse_args()
 spec=importlib.util.spec_from_file_location('input_builder',ROOT/'tools/build-input.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);m.verify_sources()
 rom=a.rom_root.resolve();tools=rom/'out/host/linux-x86/bin';frames=ROOT/'proprietary';raw=frames/'system/system/app/BluetoothExtension/BluetoothExtension.apk'
 work=a.keep_work or Path(tempfile.mkdtemp(prefix='nabu-stylus-ota-'));work.mkdir(parents=True,exist_ok=True)
 try:
  cache=work/'framework';cache.mkdir(exist_ok=True)
  for rel in ['system/system/framework/framework-res.apk','system_ext/framework/framework-ext-res/framework-ext-res.apk','system_ext/app/miuisystem/miuisystem.apk']:run('apktool','if','-p',cache,frames/rel)
  decoded=work/'decoded';run('apktool','d','-f','-s','-p',cache,'-o',decoded,raw)
  tree=ET.parse(decoded/'AndroidManifest.xml');root=tree.getroot();ET.register_namespace('android',NS)
  root.attrib.pop(f'{{{NS}}}sharedUserId',None)
  app=root.find('application');app.set(f'{{{NS}}}name','org.pixelos.nabu.compat.NabuBleApplication')
  app.attrib.pop(f'{{{NS}}}persistent',None)
  for child in list(app):
   if child.tag=='service' and child.get(f'{{{NS}}}name') in SERVICES:
    child.set(f'{{{NS}}}permission','android.permission.BLUETOOTH_PRIVILEGED')
   elif child.tag=='uses-library' and child.get(f'{{{NS}}}name')=='org.apache.http.legacy':pass
   else:app.remove(child)
  assert {e.get(f'{{{NS}}}name') for e in app.findall('service')}==SERVICES
  # Retain only permissions required by these original services, not unrelated headphones/cloud/account components.
  needed={'android.permission.INTERNET','android.permission.ACCESS_NETWORK_STATE','android.permission.ACCESS_WIFI_STATE',
   'android.permission.BLUETOOTH','android.permission.BLUETOOTH_ADMIN','android.permission.BLUETOOTH_SCAN',
   'android.permission.BLUETOOTH_CONNECT','android.permission.BLUETOOTH_ADVERTISE','android.permission.BLUETOOTH_PRIVILEGED',
   'android.permission.WRITE_SECURE_SETTINGS','android.permission.WRITE_SETTINGS','android.permission.WAKE_LOCK',
   'android.permission.FOREGROUND_SERVICE','android.permission.LOCAL_MAC_ADDRESS'}
  for child in list(root):
   if child.tag in ['permission','uses-permission']:root.remove(child)
  for name in sorted(needed):
   item=ET.SubElement(root,'uses-permission',{f'{{{NS}}}name':name})
   if name=='android.permission.BLUETOOTH_SCAN':item.set(f'{{{NS}}}usesPermissionFlags','neverForLocation')
  tree.write(decoded/'AndroidManifest.xml',encoding='utf-8',xml_declaration=True)
  run('apktool','b','-p',cache,'-o',work/'manifest.apk',decoded)
  with zipfile.ZipFile(work/'manifest.apk') as z:manifest=z.read('AndroidManifest.xml')
  classes=work/'classes';dexout=work/'dex';classes.mkdir(exist_ok=True);dexout.mkdir(exist_ok=True)
  src=ROOT/'input/compat/src';files=[src/'miui/os/Build.java',src/'miui/util/FeatureParser.java',src/'miui/util/AppConstants.java',ROOT/'input/ble-compat/src/org/pixelos/nabu/compat/NabuBleApplication.java']
  platform=rom/'out/soong/.intermediates/frameworks/base/framework/android_common/turbine-combined/framework.jar';sdk=rom/'prebuilts/sdk/current/public/android.jar'
  run('javac','-source','17','-target','17','-Xlint:-options','-classpath',str(platform)+':'+str(sdk),'-d',classes,*files)
  run(tools/'d8','--min-api','33','--lib',sdk,'--output',dexout,*sorted(classes.rglob('*.class')))
  run('java','-jar',rom/'prebuilts/extract-tools/common/smali/smali.jar','a',ROOT/'input/ble-framework-smali','-o',work/'touchfeature.dex')
  assert (work/'touchfeature.dex').read_bytes().startswith(b'dex\n'), 'Smali did not produce a valid DEX'
  with zipfile.ZipFile(raw) as srczip,zipfile.ZipFile(work/'unsigned.apk','w') as dst:
   for info in srczip.infolist():
    if info.filename.startswith('META-INF/') and info.filename.upper().endswith(('.RSA','.SF','.DSA','.EC','MANIFEST.MF')):continue
    dst.writestr(info,manifest if info.filename=='AndroidManifest.xml' else srczip.read(info.filename))
   dst.writestr('classes2.dex',(dexout/'classes.dex').read_bytes(),compress_type=zipfile.ZIP_DEFLATED)
   dst.writestr('classes3.dex',(work/'touchfeature.dex').read_bytes(),compress_type=zipfile.ZIP_DEFLATED)
   dst.writestr('assets/nabu_features.xml',(frames/'product/etc/device_features/nabu.xml').read_bytes())
  run(tools/'zipalign','-f','-P','16','4',work/'unsigned.apk',work/'aligned.apk')
  keys=rom/'build/make/target/product/security';run(tools/'apksigner','sign','--key',keys/'platform.pk8','--cert',keys/'platform.x509.pem','--out',work/'signed.apk',work/'aligned.apk');run(tools/'apksigner','verify',work/'signed.apk')
  with zipfile.ZipFile(raw) as orig,zipfile.ZipFile(work/'signed.apk') as patched:
   for name in orig.namelist():
    if name.startswith(('res/','assets/','lib/')) or name in ['resources.arsc','classes.dex']:assert orig.read(name)==patched.read(name),name
  output=ROOT/'proprietary/ported/system_ext/priv-app/NabuStylusOta/NabuStylusOta.apk';output.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(work/'signed.apk',output)
  record(ROOT,output,files+[Path(__file__).resolve(),ROOT/'proprietary-input.sha256sum',raw,frames/'product/etc/device_features/nabu.xml']+sorted((ROOT/'input/ble-framework-smali').rglob('*.smali')),platform)
  print('Built focused original OTA companion:',output)
  print('Original primary DEX, resources, native payload and firmware protocol retained; only three services exposed.')
 finally:
  if not a.keep_work:shutil.rmtree(work)
if __name__=='__main__':main()
