// SPDX-License-Identifier: Apache-2.0
package org.pixelos.nabu.compat;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

/** Non-exported receiver; status is supplied by system_server's gated HAL reader. */
public final class PenStatusReceiver extends BroadcastReceiver {
    private static final String ACTION="org.pixelos.nabu.action.PEN_CHARGING_STATUS";
    private static final String CHANNEL="nabu_pen_charging";
    private static final String TAG="NabuPenCharging";
    private static final int ID=0x4e50454e;
    @Override public void onReceive(Context context,Intent intent) {
        if(!ACTION.equals(intent.getAction()))return;
        NotificationManager manager=context.getSystemService(NotificationManager.class);
        if(manager==null)return;
        int battery=intent.getIntExtra("battery",-1);
        if(battery<0||battery>100||!manager.areNotificationsEnabled()) {
            manager.cancel(TAG,ID);return;
        }
        try {
            manager.createNotificationChannel(new NotificationChannel(CHANNEL,
                    HardwareControls.tr("펜 배터리","Pen battery"),NotificationManager.IMPORTANCE_LOW));
            Intent settings=new Intent().setComponent(new ComponentName("com.miui.miinput",
                    "com.miui.miinput.stylus.KeyBoardAndStylusSettingsActivity"));
            PendingIntent content=PendingIntent.getActivity(context,ID,settings,
                    PendingIntent.FLAG_UPDATE_CURRENT|PendingIntent.FLAG_IMMUTABLE);
            Notification notification=new Notification.Builder(context,CHANNEL)
                    .setSmallIcon(android.R.drawable.ic_menu_edit)
                    .setContentTitle(HardwareControls.tr("Xiaomi 펜 충전 상태","Xiaomi pen charging status"))
                    .setContentText(HardwareControls.tr("배터리 ","Battery ")+battery+"%")
                    .setContentIntent(content).setCategory(Notification.CATEGORY_STATUS)
                    .setVisibility(Notification.VISIBILITY_PRIVATE).setOnlyAlertOnce(true)
                    .setShowWhen(false).setAutoCancel(true).build();
            manager.notify(TAG,ID,notification);
        } catch(RuntimeException e){Log.w(TAG,"Cannot update pen notification",e);}
    }
}
