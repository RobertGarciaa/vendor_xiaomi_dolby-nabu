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
    private static final int STATUS_ID = 0x4e414256;
    private static final java.util.concurrent.ExecutorService STATUS_WORKER = java.util.concurrent.Executors.newSingleThreadExecutor();
    private static final int MENU_ID = 0x4e414255;
    static String tr(String ko, String en) { return "ko".equals(Locale.getDefault().getLanguage()) ? ko : en; }
    public static void addMenu(Menu menu) {
        menu.add(Menu.NONE, MENU_ID, Menu.NONE, tr("하드웨어 제어", "Hardware controls"))
            .setShowAsAction(MenuItem.SHOW_AS_ACTION_NEVER);
        MenuItem status = menu.add(Menu.NONE, STATUS_ID, Menu.NONE, tr("펜 충전 상태 확인 중…", "Reading pen charging status…"));
        status.setEnabled(false);
        STATUS_WORKER.execute(() -> {
            String title;
            try { title = penSummary(read()); }
            catch (Exception e) { title = tr("펜 충전 상태: 확인 불가", "Pen charging status: unavailable"); }
            final String text = title;
            new android.os.Handler(android.os.Looper.getMainLooper()).post(() -> status.setTitle(text));
        });
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
            int[] state = new int[8];
            for (int i = 0; i < 6; ++i) state[i] = data.getInt32(i * 4L);
            HwParcel penRequest = new HwParcel(), penReply = new HwParcel();
            try {
                penRequest.writeInterfaceToken(DESCRIPTOR);
                service().transact(3, penRequest, penReply, 0);
                penReply.verifySuccess();
                state[6] = penReply.readInt32(); state[7] = penReply.readInt32();
            } finally { penRequest.releaseTemporaryStorage(); penReply.release(); }
            // A later charging-link sample can invalidate a previously valid measurement.
            if (state[6] != 1 || state[7] != 4) state[4] = state[5] = -1;
            return state;
        } finally { request.releaseTemporaryStorage(); reply.release(); }
    }
    static String penSummary(int[] state) {
        if (state[6] < 0 || state[7] < 0) return tr("정품 펜 충전 상태: 확인 불가", "Xiaomi pen charging status: unavailable");
        if (state[6] != 1) return tr("정품 펜 충전 통신 없음", "No Xiaomi pen charging link");
        if (state[7] == 4) return tr("정품 펜 충전 통신 감지됨", "Xiaomi pen charging link detected")
            + (state[4] < 0 ? tr(" · 잔량 확인 불가", " · battery unavailable") : " · " + state[4] + "%");
        return tr("정품 펜 충전 통신 확인 안 됨", "Xiaomi pen charging link not established");
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
