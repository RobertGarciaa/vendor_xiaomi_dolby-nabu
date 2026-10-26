// SPDX-License-Identifier: Apache-2.0
package org.pixelos.nabu.compat;

import android.app.Activity;
import android.os.Bundle;
import android.os.UserHandle;
import android.view.MenuItem;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import static org.pixelos.nabu.compat.HardwareControls.tr;

/** Supplemental controls inside the original app; hardware state is never inferred from IME state. */
public final class HardwareControlsActivity extends Activity {
    private final ExecutorService worker = Executors.newSingleThreadExecutor();
    private final Switch[] controls = new Switch[3];
    private TextView status;
    private boolean updating, busy;
    private int[] state;
    @Override public void onCreate(Bundle saved) {
        super.onCreate(saved);
        setTitle(tr("하드웨어 제어", "Hardware controls"));
        if (getActionBar() != null) getActionBar().setDisplayHomeAsUpEnabled(true);
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        int pad = (int)(20 * getResources().getDisplayMetrics().density);
        layout.setPadding(pad, pad, pad, pad);
        String[] titles = {tr("스타일러스 사용", "Enable stylus"), tr("2세대 펜 펌웨어 사용", "Use generation 2 pen firmware"), tr("키보드 사용", "Enable keyboard")};
        for (int i = 0; i < controls.length; ++i) {
            final int control = i;
            Switch button = new Switch(this); button.setText(titles[i]);
            button.setPadding(0, pad / 2, 0, pad / 2); button.setEnabled(false);
            button.setOnCheckedChangeListener((view, checked) -> { if (!updating) change(control, checked); });
            controls[i] = button; layout.addView(button);
        }
        addButtonSetting(layout, tr("기본 펜 버튼 길게 누르기", "Primary pen button long press"), "nabu_stylus_primary_action");
        addButtonSetting(layout, tr("보조 펜 버튼 길게 누르기", "Secondary pen button long press"), "nabu_stylus_secondary_action");
        TextView explanation = new TextView(this);
        explanation.setText(tr("하드웨어 스위치는 기기 전체에, 버튼 동작은 현재 사용자에게 적용됩니다. 버튼의 짧은 누르기와 앱의 펜 모션 버튼은 유지합니다. 2세대 펌웨어 변경 후 화면을 껐다 켜야 반영될 수 있습니다. 게임 모드는 펌웨어 선택에 영향을 줄 수 있습니다.",
            "Hardware switches affect the whole device; button actions apply to the current user. Short presses and app pen motion buttons are preserved. Generation 2 firmware may require a screen off/on cycle. Game mode can affect firmware selection."));
        layout.addView(explanation);
        status = new TextView(this); status.setPadding(0, pad, 0, pad); layout.addView(status);
        android.widget.Button refresh = new android.widget.Button(this);
        refresh.setText(tr("상태 새로고침", "Refresh status")); refresh.setOnClickListener(view -> { if (!busy) refresh(); }); layout.addView(refresh);
        ScrollView scroll = new ScrollView(this); scroll.addView(layout); setContentView(scroll);
    }
    private void addButtonSetting(LinearLayout layout, String title, String key) {
        TextView label = new TextView(this); label.setText(title); layout.addView(label);
        android.widget.Spinner choices = new android.widget.Spinner(this);
        String[] entries = {tr("Android 기본 동작", "Android default"), tr("빠른 노트", "Quick note"), tr("영역 캡처", "Regional screenshot")};
        android.widget.ArrayAdapter<String> adapter = new android.widget.ArrayAdapter<>(this, android.R.layout.simple_spinner_item, entries);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item); choices.setAdapter(adapter);
        int value = android.provider.Settings.Secure.getInt(getContentResolver(), key, 0);
        final int[] saved = {value >= 0 && value <= 2 ? value : 0};
        choices.setSelection(saved[0]);
        choices.setOnItemSelectedListener(new android.widget.AdapterView.OnItemSelectedListener() {
            @Override public void onNothingSelected(android.widget.AdapterView<?> parent) {}
            @Override public void onItemSelected(android.widget.AdapterView<?> parent, android.view.View view, int position, long id) {
                if (position == saved[0]) return;
                if (android.provider.Settings.Secure.putInt(getContentResolver(), key, position)) saved[0] = position;
                else { choices.setSelection(saved[0]); Toast.makeText(HardwareControlsActivity.this, tr("버튼 설정을 저장하지 못했습니다.", "Could not save button setting."), Toast.LENGTH_LONG).show(); }
            }
        });
        layout.addView(choices);
    }
    @Override public void onResume() { super.onResume(); if (!busy) refresh(); }
    private void refresh() { submit(-1, false); }
    private void change(int control, boolean checked) { submit(control, checked); }
    private void submit(int control, boolean checked) {
        busy = true; render();
        worker.execute(() -> {
            int result = 0; int[] fresh = null; Exception error = null;
            try { if (control >= 0) result = HardwareControls.set(control, checked); fresh = HardwareControls.read(); }
            catch (Exception failure) { error = failure; }
            final int rc = result; final int[] next = fresh; final Exception failure = error;
            runOnUiThread(() -> {
                if (isFinishing() || isDestroyed()) return;
                busy = false; state = next; render();
                if (failure != null) {
                    android.util.Log.e("NabuInput", "Hardware service request failed", failure);
                    status.setText(tr("하드웨어 서비스에 연결할 수 없습니다.", "Hardware service unavailable."));
                } else if (rc != 0) Toast.makeText(this, tr("설정을 적용하거나 저장하지 못했습니다. 오류: ", "Could not apply or save setting. Error: ") + rc, Toast.LENGTH_LONG).show();
            });
        });
    }
    private void render() {
        boolean owner = UserHandle.myUserId() == 0;
        updating = true;
        for (int i = 0; i < controls.length; ++i) {
            if (state != null) controls[i].setChecked(state[i] == 1);
            controls[i].setEnabled(!busy && owner && state != null && state[i] >= 0);
        }
        updating = false;
        if (state == null) { status.setText(tr("상태를 읽는 중…", "Reading hardware state…")); return; }
        String unknown = tr("확인 불가", "Unavailable");
        status.setText(tr("키보드 연결: ", "Keyboard connection: ") + (state[3] < 0 ? unknown : state[3] == 1 ? tr("연결됨", "Connected") : tr("연결 안 됨", "Disconnected"))
            + "\n" + tr("펜 배터리 측정값: ", "Pen battery reading: ") + (state[4] < 0 ? unknown : state[4] + "%")
            + "\n" + tr("펜 충전 전류: ", "Pen charging current: ") + (state[5] < 0 ? unknown : state[5] + " mA")
            + "\n" + tr("키보드 사용 스위치는 저장된 사용 설정을 표시합니다. 배터리·전류 값만으로 펜 연결 여부를 판단하지 않습니다.", "The keyboard switch shows the saved enable setting. Battery/current readings do not determine whether the pen is connected.")
            + (owner ? "" : "\n" + tr("기기 소유자만 설정을 변경할 수 있습니다.", "Only the device owner can change these settings.")));
    }
    @Override public boolean onOptionsItemSelected(MenuItem item) { if (item.getItemId() == android.R.id.home) { finish(); return true; } return super.onOptionsItemSelected(item); }
    @Override public void onDestroy() { worker.shutdown(); super.onDestroy(); }
}
