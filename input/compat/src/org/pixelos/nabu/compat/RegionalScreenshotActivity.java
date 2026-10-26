package org.pixelos.nabu.compat;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Insets;
import android.graphics.Paint;
import android.graphics.Rect;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.OutcomeReceiver;
import android.view.MotionEvent;
import android.view.View;
import android.window.ScreenCapture;
import android.widget.Toast;
import com.android.internal.util.ScreenshotHelper;
import com.android.internal.util.ScreenshotRequest;

/** Regional capture backend for the stock keyboard/stylus action. */
public final class RegionalScreenshotActivity extends Activity {
    private Bitmap screenshot;
    private boolean closing;
    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().setBackgroundDrawableResource(android.R.color.transparent);
        ScreenCapture.capture(new ScreenCapture.ScreenCaptureParams.Builder(getDisplay().getDisplayId()).build(),
                getMainExecutor(), new OutcomeReceiver<ScreenCapture.ScreenCaptureResult,Exception>() {
                    @Override public void onResult(ScreenCapture.ScreenCaptureResult result) {
                        try (android.hardware.HardwareBuffer buffer=result.getHardwareBuffer()) {
                            Bitmap hardware=Bitmap.wrapHardwareBuffer(buffer,result.getColorSpace());
                            if (hardware==null) throw new IllegalStateException("Capture returned no bitmap");
                            screenshot=hardware.copy(Bitmap.Config.ARGB_8888,false);
                            hardware.recycle();
                            if (isFinishing() || isDestroyed()) {screenshot.recycle();screenshot=null;return;}
                            setContentView(new SelectionView());
                            Toast.makeText(RegionalScreenshotActivity.this,"Drag to select an area",Toast.LENGTH_SHORT).show();
                        } catch (RuntimeException failure) {fail(failure);}
                    }
                    @Override public void onError(Exception failure) {fail(failure);}
                });
    }
    private void fail(Exception e) {
        android.util.Log.e("NabuInput","Regional screenshot failed",e);
        Toast.makeText(this,"Screenshot unavailable",Toast.LENGTH_SHORT).show();finish();
    }
    private final class SelectionView extends View {
        final Paint paint=new Paint();final Rect selection=new Rect();int x,y;
        SelectionView(){super(RegionalScreenshotActivity.this);setContentDescription("Select screenshot area");}
        @Override protected void onDraw(Canvas c) {
            if(screenshot==null)return;
            paint.setAlpha(255);c.drawBitmap(screenshot,null,new Rect(0,0,getWidth(),getHeight()),paint);
            paint.setColor(0x77000000);c.drawRect(0,0,getWidth(),getHeight(),paint);
            if(!selection.isEmpty()){
                c.save();c.clipRect(selection);paint.setColor(0xffffffff);
                c.drawBitmap(screenshot,null,new Rect(0,0,getWidth(),getHeight()),paint);c.restore();
                paint.setColor(0xffffffff);paint.setStyle(Paint.Style.STROKE);paint.setStrokeWidth(3);
                c.drawRect(selection,paint);paint.setStyle(Paint.Style.FILL);
            }
        }
        @Override public boolean onTouchEvent(MotionEvent e) {
            int ex=Math.max(0,Math.min(getWidth(),(int)e.getX()));
            int ey=Math.max(0,Math.min(getHeight(),(int)e.getY()));
            if(e.getActionMasked()==MotionEvent.ACTION_DOWN){x=ex;y=ey;}
            selection.set(Math.min(x,ex),Math.min(y,ey),Math.max(x,ex),Math.max(y,ey));invalidate();
            if(e.getActionMasked()==MotionEvent.ACTION_UP){if(selection.width()<4||selection.height()<4){finish();return true;}save(selection,getWidth(),getHeight());}
            if(e.getActionMasked()==MotionEvent.ACTION_CANCEL)finish();
            return true;
        }
    }
    private void save(Rect selected,int width,int height) {
        if(closing||screenshot==null)return;closing=true;
        float sx=(float)screenshot.getWidth()/width,sy=(float)screenshot.getHeight()/height;
        Rect bounds=new Rect((int)(selected.left*sx),(int)(selected.top*sy),(int)(selected.right*sx),(int)(selected.bottom*sy));
        try {
            Bitmap crop=Bitmap.createBitmap(screenshot,bounds.left,bounds.top,bounds.width(),bounds.height());
            // ScreenshotHelper's bitmap transport expects a HardwareBuffer-backed bitmap.
            Bitmap hardware=crop.copy(Bitmap.Config.HARDWARE,false);
            ScreenshotRequest request=new ScreenshotRequest.Builder(android.view.WindowManager.TAKE_SCREENSHOT_PROVIDED_IMAGE, android.view.WindowManager.ScreenshotSource.SCREENSHOT_KEY_OTHER).setBitmap(hardware)
                .setBoundsOnScreen(bounds).setInsets(Insets.NONE).setUserId(getUserId())
                .setDisplayId(getDisplay().getDisplayId()).build();
            new ScreenshotHelper(this).takeScreenshot(request,new Handler(Looper.getMainLooper()),uri->{hardware.recycle();finish();});
            if(crop!=screenshot)crop.recycle();
        }catch(RuntimeException failure){fail(failure);}
    }
    @Override public void onConfigurationChanged(android.content.res.Configuration c){super.onConfigurationChanged(c);finish();}
    @Override protected void onDestroy(){super.onDestroy();if(screenshot!=null){screenshot.recycle();screenshot=null;}}
}
