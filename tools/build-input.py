#!/usr/bin/env python3
"""Port the pinned Pad 5 Input Settings APK; preserve original resource/asset payloads."""
import argparse
import hashlib
import importlib.util
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zipfile
from artifact_record import record

ROOT=Path(__file__).resolve().parents[1]
NS='http://schemas.android.com/apk/res/android'
COMPAT='Lorg/pixelos/nabu/compat/AospCompat;'

def run(*args):
    subprocess.run([str(x) for x in args],check=True)

def verify_sources():
    for line in (ROOT/'proprietary-input.sha256sum').read_text().splitlines():
        digest,name=line.split(None,1)
        if hashlib.sha256((ROOT/'proprietary'/name).read_bytes()).hexdigest()!=digest:
            raise ValueError('Changed nabu stock input: '+name)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--rom-root',required=True,type=Path)
    p.add_argument('--output',type=Path,default=ROOT/'proprietary/ported/product/app/MiuiInputSettings/MiuiInputSettings.apk')
    p.add_argument('--keep-work',type=Path)
    a=p.parse_args();verify_sources()
    rom=a.rom_root.resolve(); sdk=rom/'out/host/linux-x86/bin'; jars=rom/'prebuilts/extract-tools/common/smali'
    raw=ROOT/'proprietary/product/app/MiuiInputSettings_MIUI15/MiuiInputSettings_MIUI15.apk'
    spec=importlib.util.spec_from_file_location('misound_tools',ROOT/'tools/patch-misound.py')
    m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
    work=a.keep_work or Path(tempfile.mkdtemp(prefix='nabu-input-'))
    work.mkdir(parents=True,exist_ok=True)
    try:
        smali=work/'smali'; dex=work/'classes.dex'
        with zipfile.ZipFile(raw) as z:dex.write_bytes(z.read('classes.dex'))
        run('java','-jar',jars/'baksmali.jar','d',dex,'-o',smali)
        stub=smali/'miui/hardware/input/MiuiInputManager.smali'
        assert stub.read_text().count('const/16 p0, 0x141')==1,'Unexpected stock manager stub'
        stub.unlink()
        changed=[];lookups=flags=0
        for f in smali.rglob('*.smali'):
            before=f.read_text();after=before.replace('Landroid/provider/MiuiSettings$', 'Lorg/pixelos/nabu/compat/MiuiSettings$')
            after=after.replace('Landroid/view/KeyboardShortcutInfo;', 'Lorg/pixelos/nabu/compat/KeyboardShortcutInfo;').replace('"android.view.KeyboardShortcutInfo"','"org.pixelos.nabu.compat.KeyboardShortcutInfo"')
            after,n=re.subn(r'invoke-virtual \{([^}]+)\}, L[^;]+;->getSystemService\(Ljava/lang/String;\)Ljava/lang/Object;',r'invoke-static {\1}, '+COMPAT+r'->getSystemService(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/Object;',after);lookups+=n
            after,n=re.subn(r'invoke-virtual \{([^}]+)\}, Landroid/content/Intent;->getMiuiFlags\(\)I',r'invoke-static {\1}, '+COMPAT+r'->getMiuiFlags(Landroid/content/Intent;)I',after);flags+=n
            after=re.sub(r'invoke-static \{([^}]+)\}, Landroid/app/ActivityOptions;->makeMiuiClipAnimation\(Landroid/graphics/Rect;Landroid/graphics/Rect;FFIFZ\)Landroid/app/ActivityOptions;',r'invoke-static {\1}, '+COMPAT+r'->makeMiuiClipAnimation(Landroid/graphics/Rect;Landroid/graphics/Rect;FFIFZ)Landroid/app/ActivityOptions;',after)
            after=re.sub(r'invoke-static \{([^}]+)\}, Landroid/app/ActivityOptions;->makeMiuiRoundAnimation\(FFIF\)Landroid/app/ActivityOptions;',r'invoke-static {\1}, '+COMPAT+r'->makeMiuiRoundAnimation(FFIF)Landroid/app/ActivityOptions;',after)
            after=after.replace('Landroid/app/ActivityOptions;->makeMiuiClipAnimation(',COMPAT+'->makeMiuiClipAnimation(').replace('Landroid/app/ActivityOptions;->makeMiuiRoundAnimation(',COMPAT+'->makeMiuiRoundAnimation(')
            after=after.replace('Landroid/provider/Settings$Secure;->getIntForUser(',COMPAT+'->secureGetIntForUser(').replace('Landroid/provider/Settings$Secure;->getUriFor(',COMPAT+'->secureGetUriFor(').replace('Landroid/provider/Settings$Secure;->putInt(',COMPAT+'->securePutInt(')
            after=after.replace('"enable_tap_touch_pad"','"touchpad_tap_to_click"')
            after=after.replace('Landroid/provider/Settings$System;->getIntForUser(',COMPAT+'->systemGetIntForUser(').replace('Landroid/provider/Settings$System;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I',COMPAT+'->systemGetInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I').replace('Landroid/provider/Settings$System;->getUriFor(',COMPAT+'->systemGetUriFor(').replace('Landroid/provider/Settings$System;->putInt(',COMPAT+'->systemPutInt(').replace('Landroid/provider/Settings$System;->putIntForUser(',COMPAT+'->systemPutIntForUser(')
            if after!=before:f.write_text(after);changed.append(str(f.relative_to(smali)))
        assert lookups>3 and flags==2,(lookups,flags)
        app=smali/'com/miui/miinput/MiInputApplication.smali'
        t=app.read_text();anchor='    invoke-super {p0}, Lmiuix/app/Application;->onCreate()V'
        assert t.count(anchor)==1
        app.write_text(t.replace(anchor,'    invoke-static {p0}, '+COMPAT+'->init(Landroid/app/Application;)V\n\n'+anchor))
        # Keep the original tabbed screen; add one menu entry for kernel controls.
        activity=smali/'com/miui/miinput/stylus/KeyBoardAndStylusSettingsActivity.smali'
        t=activity.read_text()
        assert 'onCreateOptionsMenu(' not in t and 'onOptionsItemSelected(' not in t
        t+='''
.method public onCreateOptionsMenu(Landroid/view/Menu;)Z
    .registers 3
    invoke-super {p0, p1}, Lt/a;->onCreateOptionsMenu(Landroid/view/Menu;)Z
    invoke-static {p1}, Lorg/pixelos/nabu/compat/HardwareControls;->addMenu(Landroid/view/Menu;)V
    const/4 v0, 0x1
    return v0
.end method

.method public onOptionsItemSelected(Landroid/view/MenuItem;)Z
    .registers 3
    invoke-static {p0, p1}, Lorg/pixelos/nabu/compat/HardwareControls;->open(Landroid/app/Activity;Landroid/view/MenuItem;)Z
    move-result v0
    if-eqz v0, :stock
    return v0
    :stock
    invoke-super {p0, p1}, Lt/a;->onOptionsItemSelected(Landroid/view/MenuItem;)Z
    move-result v0
    return v0
.end method
'''
        activity.write_text(t)
        device=smali/'d0/d.smali';t=device.read_text()
        pattern=r'\.method public static a\(Landroid/view/InputDevice;\)Z\n.*?\.end method'
        body='''.method public static a(Landroid/view/InputDevice;)Z
    .registers 1
    invoke-static {p0}, Lorg/pixelos/nabu/compat/AospCompat;->isXiaomiStylus(Landroid/view/InputDevice;)I
    move-result p0
    if-lez p0, :absent
    const/4 p0, 0x1
    return p0
    :absent
    const/4 p0, 0x0
    return p0
.end method'''
        t,n=re.subn(pattern,lambda _:body,t,flags=re.S);assert n==1;device.write_text(t)
        fixed=work/'classes-fixed.dex';run('java','-jar',jars/'smali.jar','a',smali,'-o',fixed)
        assert not m.dex_strings_sorted(fixed.read_bytes())[1]
        # Compile against the actual platform APIs; this app is platform signed.
        compat=work/'compat';classes=compat/'classes';out=compat/'dex';classes.mkdir(parents=True,exist_ok=True);out.mkdir(parents=True,exist_ok=True)
        framework=rom/'out/soong/.intermediates/frameworks/base/framework/android_common/turbine-combined/framework.jar'
        android=rom/'prebuilts/sdk/current/public/android.jar'
        sources=sorted((ROOT/'input/compat/src').rglob('*.java'))
        run('javac','-source','17','-target','17','-Xlint:-options','-classpath',str(framework)+':'+str(android),'-d',classes,*sources)
        run(sdk/'d8','--min-api','33','--lib',android,'--output',out,*sorted(classes.rglob('*.class')))
        # Match the camera port: rebuild the manifest with pinned stock resource frameworks,
        # then retain only the compiled manifest from apktool's output.
        frames=work/'framework';frames.mkdir(exist_ok=True)
        for rel in ['system/system/framework/framework-res.apk','system_ext/framework/framework-ext-res/framework-ext-res.apk','system_ext/app/miuisystem/miuisystem.apk']:
            run('apktool','if','-p',frames,ROOT/'proprietary'/rel)
        decoded=work/'decoded'
        run('apktool','d','-f','-s','-p',frames,'-o',decoded,raw)
        manifest=decoded/'AndroidManifest.xml';tree=ET.parse(manifest);root=tree.getroot();app=root.find('application')
        ET.register_namespace('android',NS)
        for permission in ['android.permission.READ_FRAME_BUFFER','android.permission.WRITE_SECURE_SETTINGS','android.permission.POST_NOTIFICATIONS']:
            ET.SubElement(root,'uses-permission',{f'{{{NS}}}name':permission})
        service=next(e for e in app.findall('service') if e.get(f'{{{NS}}}name')=='com.miui.miinput.service.MiuiInputSettingsService')
        service.set(f'{{{NS}}}permission','android.permission.STATUS_BAR_SERVICE')
        ET.SubElement(app,'activity',{
            f'{{{NS}}}name':'org.pixelos.nabu.compat.RegionalScreenshotActivity',
            f'{{{NS}}}exported':'true',f'{{{NS}}}excludeFromRecents':'true',
            f'{{{NS}}}permission':'android.permission.STATUS_BAR_SERVICE',
            f'{{{NS}}}theme':'@android:style/Theme.Translucent.NoTitleBar.Fullscreen',
            f'{{{NS}}}configChanges':'orientation|screenSize|screenLayout|smallestScreenSize'})
        ET.SubElement(app,'activity',{
            f'{{{NS}}}name':'org.pixelos.nabu.compat.HardwareControlsActivity',
            f'{{{NS}}}exported':'false',
            f'{{{NS}}}theme':'@android:style/Theme.DeviceDefault'})
        ET.SubElement(app,'receiver',{f'{{{NS}}}name':'org.pixelos.nabu.compat.PenStatusReceiver',
                                      f'{{{NS}}}exported':'false'})
        # Expose only the original stylus/keyboard screens, not unrelated MIUI gesture controls.
        for activity in app.findall('activity'):
            name=activity.get(f'{{{NS}}}name','')
            if not name.startswith(('com.miui.miinput.stylus.','com.miui.miinput.keyboard.','com.miui.miinput.keyboardlayout.','org.pixelos.nabu.compat.')):
                activity.set(f'{{{NS}}}enabled','false')
        for provider in app.findall('provider'):
            if provider.get(f'{{{NS}}}authorities')=='com.android.provider.InputSettingsSearchProvider':
                provider.set(f'{{{NS}}}exported','false')
        tree.write(manifest,encoding='utf-8',xml_declaration=True)
        run('apktool','b','-p',frames,'-o',work/'manifest.apk',decoded)
        with zipfile.ZipFile(work/'manifest.apk') as built:compiled_manifest=built.read('AndroidManifest.xml')
        with zipfile.ZipFile(raw) as zin,zipfile.ZipFile(work/'unsigned.apk','w') as zout:
            for entry in zin.infolist():
                if entry.filename.startswith('META-INF/') and entry.filename.upper().endswith(('.RSA','.DSA','.EC','.SF','MANIFEST.MF')):continue
                data=fixed.read_bytes() if entry.filename=='classes.dex' else compiled_manifest if entry.filename=='AndroidManifest.xml' else zin.read(entry.filename)
                zout.writestr(entry,data)
            zout.writestr('classes2.dex',(out/'classes.dex').read_bytes(),compress_type=zipfile.ZIP_DEFLATED)
            zout.writestr('assets/nabu_features.xml',(ROOT/'proprietary/product/etc/device_features/nabu.xml').read_bytes())
            zout.writestr('assets/nabu_shortcuts.xml',(ROOT/'input/configs/nabu-shortcuts.xml').read_bytes())
        run(sdk/'zipalign','-f','-P','16','4',work/'unsigned.apk',work/'aligned.apk')
        key=rom/'build/make/target/product/security'
        run(sdk/'apksigner','sign','--key',key/'platform.pk8','--cert',key/'platform.x509.pem','--out',work/'signed.apk',work/'aligned.apk')
        run(sdk/'apksigner','verify',work/'signed.apk')
        # Every original resource, asset and native payload stays byte-identical.
        with zipfile.ZipFile(raw) as src,zipfile.ZipFile(work/'signed.apk') as dst:
            for name in src.namelist():
                if name.startswith(('res/','assets/','lib/')) or name == 'resources.arsc':
                    assert src.read(name)==dst.read(name),name
        a.output.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(work/'signed.apk',a.output)
        record(ROOT,a.output,sources+[Path(__file__).resolve(),ROOT/'tools/patch-misound.py',ROOT/'proprietary-input.sha256sum',ROOT/'input/configs/nabu-shortcuts.xml',raw,ROOT/'proprietary/product/etc/device_features/nabu.xml'],framework)
        print('Built original nabu Input Settings:',a.output)
        print('Preserved original resources/assets; hardened manifest service access; changed %d DEX classes, %d context lookups, %d MIUI intent calls'%(len(changed),lookups,flags))
    finally:
        if not a.keep_work:shutil.rmtree(work)

if __name__=='__main__':main()
