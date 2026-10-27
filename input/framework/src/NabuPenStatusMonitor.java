/* SPDX-License-Identifier: Apache-2.0 */
package com.android.server.policy;

import android.app.ActivityManager;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.HwBinder;
import android.os.HwParcel;
import android.os.IHwBinder;
import android.os.SystemProperties;
import android.os.UEventObserver;
import android.os.UserHandle;
import android.os.UserManager;
import android.util.Log;
import java.util.concurrent.atomic.AtomicBoolean;

/** Charging telemetry only. This never infers Bluetooth or capacitive-pen presence. */
final class NabuPenStatusMonitor {
    private static final String TAG="NabuPenStatus";
    private static final String HAL="vendor.pixelos.nabu.input@1.0::IInputControl";
    private static final String ACTION="org.pixelos.nabu.action.PEN_CHARGING_STATUS";
    private static boolean started;
    private final Context context;
    private final Handler handler;
    private final AtomicBoolean queued=new AtomicBoolean();
    private boolean bootReady=SystemProperties.getBoolean("sys.boot_completed",false);
    private int lastUser=-1,lastBattery=-2,failures;
    private final Runnable poll=this::sample;
    private final UEventObserver observer=new UEventObserver() {
        @Override public void onUEvent(UEvent event) {
            String name=event.get("POWER_SUPPLY_NAME");
            if("idt".equals(name)||"wireless".equals(name))requestSample();
        }
    };
    static synchronized void start(Context context) {
        if(started||!SystemProperties.getBoolean("ro.nabu.input_port",false))return;
        started=true;
        new NabuPenStatusMonitor(context);
    }
    private NabuPenStatusMonitor(Context context) {
        this.context=context;
        HandlerThread worker=new HandlerThread(TAG);worker.start();
        handler=new Handler(worker.getLooper());
        IntentFilter events=new IntentFilter();
        events.addAction(Intent.ACTION_BOOT_COMPLETED);
        events.addAction(Intent.ACTION_USER_UNLOCKED);
        events.addAction(Intent.ACTION_USER_SWITCHED);
        events.addAction(Intent.ACTION_LOCALE_CHANGED);
        context.registerReceiverAsUser(new BroadcastReceiver() {
            @Override public void onReceive(Context c,Intent intent) {
                if(Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction()))bootReady=true;
                if(Intent.ACTION_USER_SWITCHED.equals(intent.getAction())) {
                    if(lastUser>=0)deliver(lastUser,-1);
                    lastUser=-1;
                }
                lastBattery=-2;failures=0;requestSample();
            }
        },UserHandle.ALL,events,null,handler,Context.RECEIVER_NOT_EXPORTED);
        observer.startObserving("SUBSYSTEM=power_supply");
        requestSample();
    }
    private void requestSample() {
        if(queued.compareAndSet(false,true))handler.postDelayed(()->{
            queued.set(false);sample();
        },300);
    }
    private int[] read() throws Exception {
        IHwBinder binder=HwBinder.getService(HAL,"default",false);
        if(binder==null)throw new IllegalStateException("Input HAL unavailable");
        int soc;
        HwParcel request=new HwParcel(),reply=new HwParcel();
        try {
            request.writeInterfaceToken(HAL);binder.transact(1,request,reply,0);
            reply.verifySuccess();soc=reply.readBuffer(24).getInt32(16);
        } finally {request.releaseTemporaryStorage();reply.release();}
        request=new HwParcel();reply=new HwParcel();
        try {
            request.writeInterfaceToken(HAL);binder.transact(3,request,reply,0);
            reply.verifySuccess();return new int[]{soc,reply.readInt32(),reply.readInt32()};
        } finally {request.releaseTemporaryStorage();reply.release();}
    }
    private void sample() {
        handler.removeCallbacks(poll);
        if(!bootReady)return;
        int user=ActivityManager.getCurrentUser();
        int[] state={-1,-1,-1};boolean available=false;
        try {state=read();available=true;failures=0;}
        catch(Exception e){if(failures++==0)Log.w(TAG,"Pen telemetry unavailable",e);}
        boolean active=state[1]==1&&state[2]==4;
        int battery=active&&state[0]>=0&&state[0]<=100?state[0]:-1;
        // Discard a result spanning a user switch; the switch receiver resamples.
        if(user==ActivityManager.getCurrentUser()
                &&context.getSystemService(UserManager.class).isUserUnlocked(UserHandle.of(user))) {
            if(lastUser!=user||lastBattery!=battery) {
                if(deliver(user,battery)){lastUser=user;lastBattery=battery;}
            }
        }
        // IDT caches SOC without emitting an event for every percentage update.
        // Idle/ordinary capacitive pens get no periodic wakeups. Missing HAL has
        // a bounded bootstrap retry; later power/user events may retry again.
        if(active)handler.postDelayed(poll,10000);
        else if(!available&&failures<5)handler.postDelayed(poll,30000);
    }
    private boolean deliver(int user,int battery) {
        Intent intent=new Intent(ACTION).setComponent(new ComponentName("com.miui.miinput",
                "org.pixelos.nabu.compat.PenStatusReceiver"));
        intent.putExtra("battery",battery);
        try {context.sendBroadcastAsUser(intent,UserHandle.of(user));return true;}
        catch(RuntimeException e){Log.w(TAG,"Cannot deliver pen status",e);return false;}
    }
}
