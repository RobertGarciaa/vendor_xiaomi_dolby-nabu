package miui.util;
public final class HardwareInfo {
 public static long getTotalPhysicalMemory(){android.app.ActivityManager.MemoryInfo i=new android.app.ActivityManager.MemoryInfo();AppConstants.getCurrentApplication().getSystemService(android.app.ActivityManager.class).getMemoryInfo(i);return i.totalMem;}
}
