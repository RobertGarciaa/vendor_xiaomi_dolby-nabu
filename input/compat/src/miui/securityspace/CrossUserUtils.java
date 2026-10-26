package miui.securityspace;
public final class CrossUserUtils {
 public static int getCurrentUserId(){return android.app.ActivityManager.getCurrentUser();}
 public static boolean checkUidPermission(android.content.Context c,String p){return c.checkSelfPermission(p)==android.content.pm.PackageManager.PERMISSION_GRANTED;}
}
