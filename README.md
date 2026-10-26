# Xiaomi Pad 5 stock features for PixelOS

패드5(nabu) Global HyperOS **OS1.0.6.0.TKXMIXM / Android 13**의 Dolby Atmos를
AOSP PixelOS Android 17에 통합하기 위한 저장소입니다. 전체 ROM 빌드와 실기기
검증은 아직 수행하지 않았습니다. 현재 상태는 빌드 통합과 정적 검증을 마친 포팅 후보입니다.

## 스타일러스·키보드

스톡 설정 첫 화면의 **소리 및 진동 다음 → 스타일러스 & 키보드** 위치를
PixelOS 설정에 추가합니다. 원본 MiuiInputSettings APK와 nabu 리소스 오버레이를
유지하며 Android 17 프레임워크 단축키 처리와 원본 Bluetooth OTA 서비스의
호환 포팅을 포함합니다. 재현 방법, 적용 패치, 실제 이식 범위와 남은 의존성은
[입력 기능 포팅 문서](docs/input-port.md), [검증 기록](docs/input-validation.md)을 보세요.

## 원본과 적용 범위

- 엔진: 패드5 스톡 `libhwdap.so` (ARM32/ARM64), DMS HAL 2.0 및 관련 라이브러리.
- 튜닝: 패드5 스톡 `vendor/etc/dolby/dax-default.xml` 원본 그대로.
- DSP: 패드5 스톡 `vendor/lib/rfsa/adsp/capi_v2_dap_cpdp.so` 원본 그대로.
- UI: 패드5 스톡 `product/app/MiSound/MiSound.apk`를 호환성 보정하여 사용.
- 설정·QS·효과 수명 관리: renoir DolbyControl 소스를 참고하여 패드5 HW DAP에 연결.
- 기존 AOSP 일반 효과·전처리·볼륨 리스너는 보존하고 Atmos만 추가합니다.
  Game DAP, VQE, Dolby 미디어 디코더, MiSound의 다른 MIUI 전용 기능은 추가하지 않습니다.

참고 구현은 `/home/ccc/android/예비/renoir/vendor/xiaomi/dolby-renoir`,
커밋 `7aaea82`입니다. 그 저장소의 Poco X5 Pro 엔진, Xiaomi 12 Lite 튜닝,
Redwood APK는 가져오지 않았습니다. Atmos 원본 스톡 파일 15개는 해시와 함께 Git에
포함했습니다. 파생 APK는 `proprietary/ported/`에 생성하며 Git에서 제외합니다.

## 빌드 트리에 배치

이 저장소의 Android 빌드 경로는 반드시 **`vendor/xiaomi/dolby-nabu`**입니다.
현재 외부 작업 위치의 이름 `vendor_xiaomi_dolby-nabu`는 Git 저장소 이름입니다.
공통·기기 트리는 각각 `device/xiaomi/sm8150-common`, `device/xiaomi/nabu`에 배치합니다.

nabu `device.mk`에서 공통 트리를 상속하기 전에 `TARGET_ENABLE_XIAOMI_DOLBY ?= true`를
설정하고 이 저장소의 `dolby.mk`를 상속합니다. `BoardConfig.mk`도 동일한 선택값으로
이 저장소의 `BoardConfig.mk`를 포함합니다. `false`로 빌드하면 Dolby 앱·HAL·정책·DSP
파일을 제외하고 Dolby를 제거한 공통 효과 XML을 사용합니다.

공통 트리의 오디오 디렉터리 복사에서 `audio_effects.xml`만 조건부 처리합니다.
나머지 오디오 설정은 기존대로 복사합니다. 활성화 시 vendor 저장소만
`/vendor/etc/audio_effects.xml`을 설치하므로 복사 대상이 중복되지 않습니다.

**기존 공통 vendor blobs가 있다면 수정된 추출 목록으로 다시 생성해야 합니다.**
오래된 `vendor/xiaomi/sm8150-common/Android.bp`와 `*-vendor.mk`에 Dolby 모듈이
남으면 새 저장소와 중복됩니다. nabu vendor 생성물에서도 이전
`capi_v2_dap_cpdp.so` 복사 항목을 갱신해야 합니다. 이 작업에서는 요청받은 두 디바이스
트리와 새 저장소만 수정하며, PixelOS 소스 트리의 다른 vendor 저장소는 수정하지 않습니다.

## APK 준비 및 검증

새 체크아웃은 ROM 빌드 전에 다음을 실행합니다. JDK, ROM의 smali 도구,
`out/host/linux-x86/bin`의 d8·zipalign·apksigner 및 플랫폼 키가 필요합니다.

```bash
bash vendor/xiaomi/dolby-nabu/tools/import-misound.sh \
  --rom-root /path/to/pixelos \
  --dump /path/to/miui_NABUGlobal_OS1.0.6.0.TKXMIXM_4af37553d5_13.0
python3 vendor/xiaomi/dolby-nabu/tools/verify-port.py --rom-root /path/to/pixelos
```

현재 외부 작업 폴더에는 APK를 이미 생성해 두었습니다. 빌드 시
`android_app_import`가 빌드 대상의 플랫폼 키로 다시 서명합니다. 원본 앱의 oat/vdex는
설치하지 않으며 dex preopt를 비활성화합니다.

원본만 다시 추출하려면 `python3 extract-files.py /path/to/stock-dump`, 해시 검사는
`python3 extract-files.py --verify-only`를 실행합니다. 원본은 SHA256으로 고정하며
다른 펌웨어를 입력하면 중단합니다. VNDK30 foundation은 패드5 스톡 APEX에서 추출합니다.

## 호환성 보정

스톡 HW DAP 구현 UUID `9d4921da-8225-4f29-aefa-39537a04bcaa`를 유지합니다.
MiSound의 타입 UUID만 스톡 라이브러리의 실제 descriptor인
`46d279d9-9be7-453d-9d7c-ef937f675587`로 맞춥니다. DEX를 smali로 재조립하므로
문자열 정렬을 깨뜨리는 바이너리 문자열 치환을 하지 않습니다.

MIUI 전용 Build·FeatureParser·HapticFeedbackUtil 중 앱이 참조하는 멤버를 APK의
classes2.dex에 제공합니다. `isSupportLinearMotorVibrate(int)`도 포함합니다.
햅틱 호환 클래스는 MIUI 전용 진동 지원을 보고하지 않습니다. 패드5 APK의 실제 클래스
맵(`y/f`, `o0/c`, `r3/a`)으로 선택값 null 처리와 GEQ의 레거시 MiSound/Dirac 경로를
보정합니다. Dolby GEQ의 DAP 쓰기 경로와 UI 갱신은 유지합니다.

패드5 DMS의 EventHandler는 구형 AHandler 레이아웃을 내장합니다(카운터 +0x2c,
SortedVector +0x30, Looper +0x58, DsManager +0x60). Android 17의 foundation과
혼용하지 않도록 **패드5 자체 VNDK30 APEX**의 foundation을 `libsf_dolby_nabu.so`로
분리합니다. Soong genrule은 원본 해시를 검사한 후 DMS의 DT_NEEDED와 provider의
DT_SONAME 한 문자열씩만 바꿉니다. 플랫폼 라이브러리를 교체하지 않습니다.

SELinux는 DMS 전용 도메인·데이터 타입·HAL 속성으로 분리합니다. 서비스 데이터는
`/data/vendor/dolby`이고 audio effects HAL만 DMS 클라이언트로 지정합니다.
DolbyControl은 AudioEffect를 통해 접근하므로 앱에 DMS 직접 접근 권한을 주지 않습니다.

## 검증 상태

자세한 범위와 한계는 [docs/validation.md](docs/validation.md)를 참고하세요.
[기존 Dolby 관련 커밋 목록](docs/legacy-dolby-history.txt)도 포함했습니다.

다음은 실제 nabu 빌드 및 플래시 후 확인해야 합니다.

1. 전체 제품 빌드: Soong ELF 검사, VINTF, 분할 SELinux 정책과 neverallow 통과.
2. 부팅: `getprop ro.vendor.audio.dolby.dax.support`가 true인지, DMS가 반복 종료하지 않는지 확인.
3. `dumpsys media.audio_flinger`, `dumpsys media.audio_policy`와 logcat에서 HW DAP 로드,
   실제 DSP 경로, 미해결 심볼·SELinux denial 유무 확인.
4. 내장 스피커, USB/유선 오디오, Bluetooth 각각에서 Atmos on/off, 프로필, EQ를 청취 비교.
   HW DAP가 모든 경로에서 효과를 처리하는지는 실기기 검증 전에는 보장할 수 없습니다.
5. 스피커 회전·화면 종료·다른 앱 전환·재부팅·audioserver 재시작 후 상태 복원과
   DMS CPU 사용률 확인. 메서드 성공 반환뿐 아니라 실제 파라미터 readback과 출력 변화를 확인.

스톡 DSP·GEF 경로를 사용하는 만큼 대상 커널·오디오 HAL·펌웨어 조합의 확인이 필요합니다.
이 저장소는 기존 nabu 트리의 stock audio.primary.nabu, libqtigef 및 스피커 경로를 사용합니다.
