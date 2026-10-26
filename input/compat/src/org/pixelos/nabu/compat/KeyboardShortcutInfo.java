package org.pixelos.nabu.compat;
import android.graphics.drawable.Icon;
import org.json.JSONObject;
public final class KeyboardShortcutInfo {
 private CharSequence label; private Icon icon; private long key,history;private boolean active=true,customized=true;private int type;private String pkg="",cls="";
 public KeyboardShortcutInfo(CharSequence label,int keycode,int modifiers){this.label=label;key=((long)modifiers<<32)|(keycode&0xffffffffL);}
 public CharSequence getLabel(){return label;}public void setLabel(CharSequence value){label=value;}public void setIcon(Icon value){icon=value;} public Icon getIcon(){return icon;}public char getBaseCharacter(){return 0;}public int getKeycode(){return (int)key;}public int getModifiers(){return (int)(key>>>32);}
 public long getShortcutKeyCode(){return key;}public void setShortcutKeyCode(long v){key=v;}public long getHistoryKeyCode(){return history;}public void setHistoryKeyCode(long v){history=v;}
 public boolean isActive(){return active;}public void setActive(boolean v){active=v;}public boolean isCustomized(){return customized;}public void setCustomized(boolean v){customized=v;}
 public int getType(){return type;}public void setType(int v){type=v;}public String getPackageName(){return pkg;}public String getClassName(){return cls;}public void setAppInfo(String p,String c){pkg=p;cls=c;}
 public JSONObject toJson(){try{return new JSONObject().put("key",key).put("history",history).put("active",active).put("customized",customized).put("type",type).put("package",pkg).put("class",cls).put("label",label==null?"":label.toString());}catch(org.json.JSONException e){throw new IllegalStateException(e);}}
 public static KeyboardShortcutInfo fromJson(JSONObject j){KeyboardShortcutInfo i=new KeyboardShortcutInfo(j.optString("label"),(int)j.optLong("key"),(int)(j.optLong("key")>>>32));i.history=j.optLong("history");i.active=j.optBoolean("active",true);i.customized=j.optBoolean("customized",true);i.type=j.optInt("type");i.pkg=j.optString("package");i.cls=j.optString("class");return i;}
}
