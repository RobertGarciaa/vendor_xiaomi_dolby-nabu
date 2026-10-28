"""Checked-in SDK fallbacks for APK inspection before building out/host tools."""
from pathlib import Path

def command(rom, name, *args):
    rom = Path(rom)
    built = rom / 'out/host/linux-x86/bin' / name
    if built.is_file():
        return [str(built), *map(str, args)]
    sdk = rom / 'prebuilts/sdk/tools/linux'
    if name == 'apksigner':
        # The source SDK launcher's installed-SDK JAR paths do not match this tree.
        java = rom / 'prebuilts/jdk/jdk21/linux-x86/bin/java'
        jar = sdk / 'lib/apksigner.jar'
        if java.is_file() and jar.is_file():
            return [str(java), '-jar', str(jar), *map(str, args)]
    else:
        tool = sdk / 'bin' / name
        if tool.is_file():
            return [str(tool), *map(str, args)]
    raise FileNotFoundError(f'{name}: neither built host tool nor source SDK tool is available')
