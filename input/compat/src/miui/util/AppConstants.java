package miui.util;
public final class AppConstants {
 public static android.app.Application application;
 public static android.app.Application getCurrentApplication(){return application;}
 public static int getSdkLevel(android.content.Context c,String p){try {android.content.pm.ApplicationInfo i=c.getPackageManager().getApplicationInfo(p,android.content.pm.PackageManager.GET_META_DATA);return i.metaData==null?0:i.metaData.getInt("miui.sdk.level",0);}catch(android.content.pm.PackageManager.NameNotFoundException e){return 0;}}
}
