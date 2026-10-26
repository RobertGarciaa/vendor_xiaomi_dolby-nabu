package miui.util;
import java.util.HashMap;
import org.xmlpull.v1.XmlPullParser;
public final class FeatureParser {
 private static final HashMap<String,Boolean> values=new HashMap<>();
 private static boolean loaded;
 public static synchronized boolean getBoolean(String key,boolean fallback){
  if(!loaded){
   try(java.io.InputStream in=AppConstants.getCurrentApplication().getAssets().open("nabu_features.xml")){
    XmlPullParser p=android.util.Xml.newPullParser();p.setInput(in,"UTF-8");
    for(int e=p.getEventType();e!=XmlPullParser.END_DOCUMENT;e=p.next()){
     if(e==XmlPullParser.START_TAG && "bool".equals(p.getName())){String n=p.getAttributeValue(null,"name");values.put(n,Boolean.parseBoolean(p.nextText()));}
    }
    loaded=true;
   }catch(Exception e){android.util.Log.w("NabuInput","Cannot load pinned nabu features",e);}
  }
  return values.getOrDefault(key,fallback);
 }
 public static String getString(String key){if("vendor".equals(key))return "qcom";if("device".equals(key))return android.os.Build.DEVICE;return null;}
 public static int[] getIntArray(String key){return null;}
}
