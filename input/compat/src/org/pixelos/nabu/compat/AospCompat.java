package org.pixelos.nabu.compat;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.view.InputDevice;
public final class AospCompat {
 public static void init(Application a){miui.util.AppConstants.application=a;}
 public static Object getSystemService(Context c,String n){return "MiuiInputManager".equals(n)?new miui.hardware.input.MiuiInputManager(c):c.getSystemService(n);}
 public static int getMiuiFlags(Intent i){return 0;}
 // Exact stock nabu InputDevice VID/PID mapping; no device-name heuristic.
 public static int isXiaomiStylus(InputDevice d){if(d==null)return 0;int v=d.getVendorId(),p=d.getProductId();if(v==0x1915&&p==0xeaea)return 1;if(v==0x1915&&p==0x4d81)return 2;if(v==0x22&&p==0x4d80)return 3;return 0;}
 public static boolean isXiaomiKeyboard(InputDevice d){return d!=null&&d.getVendorId()==12806&&d.getProductId()==16380;}
 public static android.app.ActivityOptions makeMiuiClipAnimation(android.graphics.Rect a,android.graphics.Rect b,float c,float d,int e,float f,boolean g){return android.app.ActivityOptions.makeBasic();}
 public static android.app.ActivityOptions makeMiuiRoundAnimation(float a,float b,int c,float d){return android.app.ActivityOptions.makeBasic();}
 public static int secureGetIntForUser(android.content.ContentResolver r,String key,int fallback,int user){
  if("mouse_gesture_naturalscroll".equals(key))return android.provider.Settings.System.getIntForUser(r,android.provider.Settings.System.MOUSE_REVERSE_VERTICAL_SCROLLING,fallback,user);
  return android.provider.Settings.Secure.getIntForUser(r,key,fallback,user);
 }
 public static android.net.Uri secureGetUriFor(String key){
  return "mouse_gesture_naturalscroll".equals(key)?android.provider.Settings.System.getUriFor(android.provider.Settings.System.MOUSE_REVERSE_VERTICAL_SCROLLING):android.provider.Settings.Secure.getUriFor(key);
 }
 public static boolean securePutInt(android.content.ContentResolver r,String key,int value){
  return "mouse_gesture_naturalscroll".equals(key)?android.provider.Settings.System.putIntForUser(r,android.provider.Settings.System.MOUSE_REVERSE_VERTICAL_SCROLLING,value,android.os.UserHandle.USER_CURRENT):android.provider.Settings.Secure.putInt(r,key,value);
 }
 public static int systemGetIntForUser(android.content.ContentResolver r,String key,int fallback,int user){
  if("stylus_handwriting_enable".equals(key))return android.provider.Settings.Secure.getIntForUser(r,android.provider.Settings.Secure.STYLUS_HANDWRITING_ENABLED,1,user);
  return android.provider.Settings.System.getIntForUser(r,key,fallback,user);
 }
 public static int systemGetInt(android.content.ContentResolver r,String key,int fallback){return systemGetIntForUser(r,key,fallback,android.os.UserHandle.USER_CURRENT);}
 public static boolean systemPutIntForUser(android.content.ContentResolver r,String key,int value,int user){
  return "stylus_handwriting_enable".equals(key)?android.provider.Settings.Secure.putIntForUser(r,android.provider.Settings.Secure.STYLUS_HANDWRITING_ENABLED,value,user):android.provider.Settings.System.putIntForUser(r,key,value,user);
 }
 public static boolean systemPutInt(android.content.ContentResolver r,String key,int value){return systemPutIntForUser(r,key,value,android.os.UserHandle.USER_CURRENT);}
 public static android.net.Uri systemGetUriFor(String key){return "stylus_handwriting_enable".equals(key)?android.provider.Settings.Secure.getUriFor(android.provider.Settings.Secure.STYLUS_HANDWRITING_ENABLED):android.provider.Settings.System.getUriFor(key);}
}
