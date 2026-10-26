package miui.os;
public final class Build {
 public static final String DEVICE=android.os.Build.DEVICE;
 public static final boolean IS_TABLET=android.os.SystemProperties.get("ro.build.characteristics", "").contains("tablet");
 public static final boolean IS_GLOBAL_BUILD=true, IS_INTERNATIONAL_BUILD=true, IS_STABLE_VERSION=true, IS_DEVELOPMENT_VERSION=false;
 public static boolean hasCameraFlash(android.content.Context c) {return c.getPackageManager().hasSystemFeature("android.hardware.camera.flash");}
 public static String getRegion(){return java.util.Locale.getDefault().getCountry();}
}
