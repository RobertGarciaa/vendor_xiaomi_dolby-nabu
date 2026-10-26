// SPDX-License-Identifier: Apache-2.0
package org.pixelos.nabu.compat;

import android.app.Activity;
import android.content.Intent;
import android.os.HwBinder;
import android.os.HwBlob;
import android.os.HwParcel;
import android.os.IHwBinder;
import android.view.Menu;
import android.view.MenuItem;
import java.util.Locale;

/** App-side client for the product's explicit, versioned HIDL control boundary. */
public final class HardwareControls {
    private static final String DESCRIPTOR = "vendor.pixelos.nabu.input@1.0::IInputControl";
    private static final int MENU_ID = 0x4e414255;
    static String tr(String ko, String en) { return "ko".equals(Locale.getDefault().getLanguage()) ? ko : en; }
    public static void addMenu(Menu menu) {
        menu.add(Menu.NONE, MENU_ID, Menu.NONE, tr("하드웨어 제어", "Hardware controls"))
            .setShowAsAction(MenuItem.SHOW_AS_ACTION_NEVER);
    }
    public static boolean open(Activity activity, MenuItem item) {
        if (item.getItemId() != MENU_ID) return false;
        activity.startActivity(new Intent(activity, HardwareControlsActivity.class));
        return true;
    }
    private static IHwBinder service() throws Exception {
        // Never wait for a missing service on startup or on the UI thread.
        IHwBinder binder = HwBinder.getService(DESCRIPTOR, "default", false);
        if (binder == null) throw new IllegalStateException("Nabu input service unavailable");
        return binder;
    }
    static int[] read() throws Exception {
        HwParcel request = new HwParcel(), reply = new HwParcel();
        try {
            request.writeInterfaceToken(DESCRIPTOR);
            service().transact(1, request, reply, 0);
            reply.verifySuccess();
            HwBlob data = reply.readBuffer(24);
            int[] state = new int[6];
            for (int i = 0; i < state.length; ++i) state[i] = data.getInt32(i * 4L);
            return state;
        } finally { request.releaseTemporaryStorage(); reply.release(); }
    }
    static int set(int control, boolean value) throws Exception {
        HwParcel request = new HwParcel(), reply = new HwParcel();
        try {
            request.writeInterfaceToken(DESCRIPTOR);
            request.writeInt32(control); request.writeInt32(value ? 1 : 0);
            service().transact(2, request, reply, 0);
            reply.verifySuccess(); return reply.readInt32();
        } finally { request.releaseTemporaryStorage(); reply.release(); }
    }
}
