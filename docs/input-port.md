# Pad 5 original stylus and keyboard port

대상은 nabu Global OS1.0.6.0.TKXMIXM Android 13 → PixelOS Android 17입니다.
원본 설정 메뉴는 Settings 첫 화면의 Sound & vibration 다음에 있는
`stylus_and_keyboard_settings` 헤더입니다. 대상 activity는
`com.miui.miinput/com.miui.miinput.stylus.KeyBoardAndStylusSettingsActivity`입니다.
PixelOS에서도 같은 위치에 “스타일러스 & 키보드”로 연결합니다.

## 구현

- 원본 MiuiInputSettings 앱의 리소스·assets·네이티브 라이브러리와 nabu RRO를 보존합니다.
  MIUI 전용 API 참조는 앱 내부 호환 클래스로 바꾸고 DEX를 다시 조립합니다.
  renoir miuicamera의 원본 페이로드 보존/국소 호환 방식을 참고했습니다.
- 앱에 포함된 원본 MiuiInputManager는 스텁입니다. 실제 장치 조회와 사용자별
  단축키 저장·편집을 구현하고 system_server의 NabuInputPolicy에 연결했습니다.
- KeyGestureController의 기본 단축키 처리 전에 진입합니다. 원본 편집기의
  유효성 플래그를 전경 앱에 한정해 반영하고 AltGr·좌우 Alt를 구분합니다.
  스톡 기본 단축키 10개와 원본 type 0..8 동작을 지원합니다.
- 스톡 VID/PID로 펜 세대를 식별하고 380ms 길게 누르기를 처리합니다.
  짧은 페이지 키는 재전달하며 노트 앱 내 페이지 동작을 유지합니다.
  원본 노트 intent를 우선하고 표준 Android 노트 intent를 대안으로 사용합니다.
  영역 캡처는 실제 화면 선택 후 Android ScreenshotHelper에 전달합니다.
- 원본 BluetoothExtension의 주 DEX·펌웨어 assets를 유지한 별도 앱에 원본
  StylusOtaService/MiuiBleOobHelperService/MiuiKeyboardOobService만 노출합니다.
  AOSP Bluetooth 스택과 shared UID를 대체하지 않습니다. 원본 ITouchFeature
  HIDL 어댑터와 전용 SELinux 도메인을 포함합니다. 스톡 TouchFeature HAL은
  현재 crDroid 커널과 맞지 않아 기본 설치에서 제외하며, 완전한 HAL 대체는 미구현입니다.
- 필기 토글은 실제 AOSP STYLUS_HANDWRITING_ENABLED, 마우스 자연 스크롤과
  터치패드 탭은 실제 AOSP 설정으로 연결합니다. 다른 MIUI 서비스가 없는 기능은
  지원한다고 가장하지 않습니다.

## 새 체크아웃 준비

저장소는 `vendor/xiaomi/dolby-nabu`에 배치합니다. 기존 Atmos 준비도 필요합니다.
아래 명령은 ROM 루트에서 실행합니다. 빌드된 framework.jar, 호스트 d8/apksigner/
zipalign/aapt2, JDK, smali, apktool과 플랫폼 키가 필요합니다.

```bash
python3 vendor/xiaomi/dolby-nabu/extract-files.py --group all --verify-only
python3 vendor/xiaomi/dolby-nabu/tools/apply-platform-patches.py --android-root "$PWD"
python3 vendor/xiaomi/dolby-nabu/tools/apply-platform-patches.py --android-root "$PWD" --apply
python3 vendor/xiaomi/dolby-nabu/tools/build-input.py --rom-root "$PWD"
python3 vendor/xiaomi/dolby-nabu/tools/build-stylus-ota.py --rom-root "$PWD"
python3 vendor/xiaomi/dolby-nabu/tools/verify-input.py --rom-root "$PWD"
```

정규 패치 관리 위치는 `vendor/extraPatches`의 **seventeen_nabu** 브랜치입니다.
`patches/frameworks_base/0004-*`와 `patches/packages_apps_Settings/0002-*`에
메일 패치를 추가했으며 기존 vendorsetup.sh의 git am 순서로 후속 적용합니다.
현재 프레임워크와 Settings 소스에는 이 포팅 변경을 적용하거나 커밋하지 않습니다.
위 직접 적용 명령은 독립 체크아웃에서 수동 적용할 때의 대안이며, extraPatches로
적용한다면 중복 실행하지 않습니다.

패치 적용기는 고정된 원본 해시를 확인하고 변경된 소스에는 덮어쓰지 않습니다.
이미 정확하게 적용된 패치는 인식합니다. 브랜치 변경 시 직접 검토해 리베이스해야 합니다.
생성 APK와 소스 해시 기록은 `proprietary/ported/`에 두며 Git에서 제외합니다.
원본 파일은 `proprietary-input.*`로 고정합니다. 원본 oat/vdex는 설치하지 않습니다.

nabu device.mk와 BoardConfig.mk는 `TARGET_ENABLE_XIAOMI_INPUT ?= true`로
각각 input/input.mk와 input/BoardConfig.mk를 포함합니다. 다른 제품에서는
읽기 전용 속성이 없으므로 새 프레임워크 처리와 설정 항목을 활성화하지 않습니다.

## 남은 기능 경계

원본 UI를 유지했다고 스톡의 모든 하드웨어 기능이 검증된 것은 아닙니다.
USB 키보드 OEM 인증/벤더 보고서/펌웨어 전송 전체 서비스는 이식하지 않았습니다.
연결 여부는 실제 AOSP HID 장치를 조회하며 getKeyboardType의 0x141은 원본 앱의
표시용 기본값이지 펌웨어에서 읽은 값이 아닙니다.

원본 BLE 서비스와 HAL은 포함했지만 실제 펜 페어링·배터리·GATT·OTA 업데이트는
nabu에서 검증해야 합니다. 보수적 도달성 조사에는 구형 miui.bluetooth.ble 타입을
참조하는 선택적 도우미도 남아 있습니다. 완전한 BLE 의존성 폐쇄를 증명하지 않았습니다.
필기는 지원 IME가 필요하며 MIUI 입력기/노트 앱은 이 저장소에서 설치하지 않습니다.
다른 모델 전용 단축키 type 9 이상과 MIUI 전용 자유 창은 지원하지 않습니다.

전체 ROM/실기기 검증 전 상태는 포팅 후보입니다. Dolby Vision은 별도로 미완료입니다.

현재 crDroid 커널의 부팅 활성화와 저장된 vendor 상태 적용은
[첫 단계 구현](crdroid-input-bootstrap.md)을 참고하세요. 원본 앱의 하드웨어 토글은 아직 추가하지 않았습니다.
