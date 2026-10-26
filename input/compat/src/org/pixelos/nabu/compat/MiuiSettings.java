package org.pixelos.nabu.compat;
import android.content.ContentResolver;
import android.content.Context;
import android.os.UserHandle;
import java.util.Collections;
import java.util.List;
public final class MiuiSettings {
 public static final class System {
  public static boolean getBoolean(ContentResolver r,String k,boolean d){return AospCompat.systemGetInt(r,k,d?1:0)!=0;}
  public static boolean getBooleanForUser(ContentResolver r,String k,boolean d,int u){return AospCompat.systemGetIntForUser(r,k,d?1:0,u)!=0;}
  public static boolean putBoolean(ContentResolver r,String k,boolean v){return AospCompat.systemPutInt(r,k,v?1:0);}
  public static boolean putBooleanForUser(ContentResolver r,String k,boolean v,int u){return AospCompat.systemPutIntForUser(r,k,v?1:0,u);}
  public static boolean putStringForUser(ContentResolver r,String k,String v,int u){return android.provider.Settings.System.putStringForUser(r,k,v,u);}
 }
 public static final class Global {public static boolean getBoolean(ContentResolver r,String k){return android.provider.Settings.Global.getInt(r,k,0)!=0;}}
 public static final class Key {
  public static String getKeyAndGestureShortcutFunction(Context c,String k){return android.provider.Settings.System.getStringForUser(c.getContentResolver(),k,UserHandle.USER_CURRENT);}
  public static boolean isTSMClientInstalled(Context c){try{c.getPackageManager().getPackageInfo("com.miui.tsmclient",0);return true;}catch(android.content.pm.PackageManager.NameNotFoundException e){return false;}}
 }
 public static final class SettingsCloudData {
  public static final class CloudData {private final String value;public CloudData(String v){value=v;}@Override public String toString(){return value;}}
  public static boolean getCloudDataBoolean(ContentResolver r,String m,String k,boolean d){android.util.Log.i("NabuInput","MIUI cloud configuration unavailable; using packaged default");return d;}
  public static List<CloudData> getCloudDataList(ContentResolver r,String m){return Collections.emptyList();}
 }
}
