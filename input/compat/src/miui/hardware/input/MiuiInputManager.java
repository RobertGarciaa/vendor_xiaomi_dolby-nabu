package miui.hardware.input;

import android.content.Context;
import android.hardware.input.InputManager;
import android.provider.Settings;
import android.view.InputDevice;
import android.widget.Toast;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.pixelos.nabu.compat.KeyboardShortcutInfo;

/** App-local input facade. Custom keys are consumed by the nabu policy source patch. */
public final class MiuiInputManager {
    public static final String SHORTCUTS = "nabu_keyboard_shortcuts";
    private final Context context;
    public MiuiInputManager(Context context) { this.context = context.getApplicationContext(); }

    public int getKeyboardType() {
        // Preserve the nabu APK's USB keyboard illustration fallback (0x141).
        // This is a presentation default, not a firmware or hardware report.
        return 0x141;
    }
    public String getMiKeyboardStatus() {
        InputManager input = context.getSystemService(InputManager.class);
        StringBuilder status = new StringBuilder();
        for (int id : input.getInputDeviceIds()) {
            InputDevice d = input.getInputDevice(id);
            if (d != null && !d.isVirtual() && d.getKeyboardType() == InputDevice.KEYBOARD_TYPE_ALPHABETIC) {
                if (status.length() != 0) status.append('\n');
                status.append(d.getName()).append(" (VID=").append(d.getVendorId())
                    .append(", PID=").append(d.getProductId()).append(')');
            }
        }
        return status.length() == 0 ? "Not connected" : status.toString();
    }
    public int[] getEdgeSuppressionSize(boolean absolute) {
        throw new UnsupportedOperationException("The MIUI edge suppression service has not been ported");
    }
    public List<KeyboardShortcutInfo> getKeyboardShortcut() {
        String value = Settings.Secure.getString(context.getContentResolver(), SHORTCUTS);
        if (value == null) return getDefaultKeyboardShortcutInfos();
        try {
            JSONArray array = new JSONArray(value);
            List<KeyboardShortcutInfo> result = new ArrayList<>();
            for (int i = 0; i < array.length(); i++) result.add(describe(KeyboardShortcutInfo.fromJson(array.getJSONObject(i))));
            return result;
        } catch (JSONException badData) {
            throw new IllegalStateException("Invalid stored keyboard shortcuts; refusing to reset them", badData);
        }
    }
    public List<KeyboardShortcutInfo> getDefaultKeyboardShortcutInfos() {
        List<KeyboardShortcutInfo> result = new ArrayList<>();
        try (java.io.InputStream stream = context.getAssets().open("nabu_shortcuts.xml")) {
            org.xmlpull.v1.XmlPullParser parser = android.util.Xml.newPullParser();
            parser.setInput(stream, "UTF-8");
            for (int event = parser.getEventType(); event != org.xmlpull.v1.XmlPullParser.END_DOCUMENT; event = parser.next()) {
                if (event != org.xmlpull.v1.XmlPullParser.START_TAG || !"ShortcutInfo".equals(parser.getName())) continue;
                int type = Integer.parseInt(attr(parser,"type","0"));
                if (!supported(type)) continue;
                int key = Integer.parseInt(attr(parser,"keycode","0"));
                int mods = (yes(parser,"meta") ? android.view.KeyEvent.META_META_ON : 0)
                        | (yes(parser,"ctrl") ? android.view.KeyEvent.META_CTRL_ON : 0)
                        | (yes(parser,"shift") ? android.view.KeyEvent.META_SHIFT_ON : 0)
                        | (yes(parser,"alt") ? android.view.KeyEvent.META_ALT_ON : 0);
                KeyboardShortcutInfo info = new KeyboardShortcutInfo(label(type), key, mods);
                info.setType(type); info.setActive(Boolean.parseBoolean(attr(parser,"enable","true")));
                info.setCustomized(Boolean.parseBoolean(attr(parser,"customized","true")));
                info.setAppInfo(attr(parser,"packageName",""),attr(parser,"className",""));
                if (type == 0) {
                    try { context.getPackageManager().getPackageInfo(info.getPackageName(),0); }
                    catch (android.content.pm.PackageManager.NameNotFoundException absent) { continue; }
                }
                result.add(describe(info));
            }
        } catch (Exception error) { throw new IllegalStateException("Cannot read pinned shortcut defaults",error); }
        return result;
    }
    private KeyboardShortcutInfo describe(KeyboardShortcutInfo info) {
        if(info.getType()!=0){info.setLabel(label(info.getType()));return info;}
        try {
            android.content.pm.ApplicationInfo app=context.getPackageManager().getApplicationInfo(info.getPackageName(),0);
            info.setLabel(context.getPackageManager().getApplicationLabel(app));
            if(app.icon!=0)info.setIcon(android.graphics.drawable.Icon.createWithResource(app.packageName,app.icon));
        }catch(android.content.pm.PackageManager.NameNotFoundException absent){info.setLabel(info.getPackageName());}
        return info;
    }
    private static String attr(org.xmlpull.v1.XmlPullParser p,String k,String d) {String s=p.getAttributeValue(null,k);return s==null?d:s;}
    private static boolean yes(org.xmlpull.v1.XmlPullParser p,String k) {return Boolean.parseBoolean(attr(p,k,"false"));}
    private String label(int type) {
        String[] names={"ks_category_app","ks_launch_control_center","ks_launch_notification_center","ks_launch_recents_tasks","ks_back_home","ks_lock_screen","ks_screenshot","ks_regional_screen_shot","ks_close_window"};
        if(type<0||type>=names.length)throw new IllegalArgumentException("Unknown stock nabu shortcut type "+type);
        int id=context.getResources().getIdentifier(names[type],"string","com.miui.miinput");
        if(id==0)throw new IllegalStateException("Original shortcut label missing: "+names[type]);
        return context.getString(id);
    }
    private static boolean supported(int type) {return type>=0&&type<=8;}
    public synchronized void updateKeyboardShortcut(KeyboardShortcutInfo info,int operation) {
        if (!supported(info.getType())) {
            Toast.makeText(context,"This MIUI window or regional screenshot action has no nabu backend yet",Toast.LENGTH_LONG).show();
            return;
        }
        List<KeyboardShortcutInfo> entries = getKeyboardShortcut();
        switch(operation) {
            case 0: case 1: case 2:
                long key = operation==1 ? info.getHistoryKeyCode() : info.getShortcutKeyCode();
                entries.removeIf(item -> item.getShortcutKeyCode()==key || item.getShortcutKeyCode()==info.getShortcutKeyCode());
                if(operation!=2) entries.add(info);
                break;
            case 3: case 4:
                boolean apps=operation==3;
                entries.removeIf(item -> (item.getType()==0)==apps);
                for(KeyboardShortcutInfo item:getDefaultKeyboardShortcutInfos()) if((item.getType()==0)==apps) entries.add(item);
                break;
            default: throw new IllegalArgumentException("Unknown shortcut operation "+operation);
        }
        JSONArray data=new JSONArray();for(KeyboardShortcutInfo item:entries)data.put(item.toJson());
        if(!Settings.Secure.putString(context.getContentResolver(),SHORTCUTS,data.toString()))
            throw new IllegalStateException("Keyboard shortcut storage rejected update");
    }
}
