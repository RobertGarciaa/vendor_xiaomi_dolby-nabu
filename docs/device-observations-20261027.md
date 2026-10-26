# 패드5 ADB 읽기 확인 — 2026-10-27

설치, 플래시, 속성 변경, sysfs 쓰기를 수행하지 않고 장치 정보만 읽었습니다.
사용자는 현재 기기가 루팅되지 않았다고 확인했습니다.
사용자는 정품 샤오미 펜·키보드를 보유하지 않고 호환펜만 있다고 확인했습니다.
따라서 정품 액세서리의 연결·인증·OOB·OTA 동작 검증은 수행할 수 없었습니다.
호환펜은 SmartDevil Capacitor Pen입니다. 블루투스 페어링과 측면 버튼이 없고,
촉 반대편의 전원 버튼만 있습니다. 아래 입력 장치 정보는 태블릿 드라이버의
기능 목록이며, 이 펜이 해당 기능을 제공한다는 관찰 결과는 아닙니다.

- 기기: Xiaomi Pad 5 / nabu / 21051182G.
- 현재 ROM: crDroid 16.0, SDK 36. 대상 PixelOS Android 17이 아닙니다.
- 현재 커널: 4.14.357-perf-g7024d865649b. 작업용 커널 체크아웃 HEAD와 다릅니다.
- 일반 ADB 셸의 /sys/touchpanel/pen, pen_gen2_force, 키보드 conn_status,
  IDT SOC/전류 읽기는 Permission denied였습니다. 노드의 실제 상태값은 읽지 못했습니다.
- dumpsys input에서 NVTCapacitivePen의 bus 0x001c, VID/PID 0/0,
  Location input/pen, IsVirtualDevice=false를 확인했습니다.
- Sources는 KEYBOARD | TOUCHSCREEN | STYLUS, keylayout은 Generic.kl입니다.
- getevent -lp에서 BTN_STYLUS와 BTN_STYLUS2, INPUT_PROP_DIRECT를 확인했습니다.
- InputDevice의 NativeBattery는 현재 <not present>, BluetoothState는 null입니다.
  입력 장치 존재만으로 실제 펜 연결이나 배터리 상태를 보고해서는 안 됩니다.

따라서 새 native-button 패치의 정확한 장치 식별 조건과 버튼 기능 목록은 실제 기기와
일치합니다. 이것은 새 APK/HAL의 실행, 실제 버튼 누르기, 길게 누르기, 배터리 값,
재부팅 복원 또는 PixelOS Android 17 동작의 검증 결과가 아닙니다.
전체 원본 dumpsys 로그는 사용자 작업 폴더의 device-check에만 보관하며 Git에 넣지 않습니다.
