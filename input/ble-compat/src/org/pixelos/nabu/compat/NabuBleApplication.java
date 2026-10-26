package org.pixelos.nabu.compat;
public final class NabuBleApplication extends android.app.Application {
    @Override public void onCreate(){super.onCreate();miui.util.AppConstants.application=this;}
}
