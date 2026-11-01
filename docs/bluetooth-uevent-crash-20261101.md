# Bluetooth 확장 반복 종료 — 2026-11-01 실기기 진단

## 확인된 원인

새 이미지에서 스타일러스·키보드 설정 진입은 가능하지만 `com.xiaomi.bluetooth`
(NabuStylusOta / Bluetooth 확장)가 반복 종료한다. ADB 크래시 버퍼와 AVC에서 확인했다.

```
Process: com.xiaomi.bluetooth
java.lang.RuntimeException: Unable to open socket for UEventObserver
  at android.os.UEventObserver.nativeSetup(Native Method)
  at android.os.UEventObserver$UEventThread.run(UEventObserver.java:195)
avc: denied { create } ... scontext=u:r:nabu_stylus_ota_app:...
  tcontext=u:r:nabu_stylus_ota_app:... tclass=netlink_kobject_uevent_socket permissive=0
```

`frameworks/base/core/jni/android_os_UEventObserver.cpp`의 nativeSetup은 uevent_init 실패 시
위 예외를 발생시킨다. `hardware/libhardware_legacy/uevent.c`는 netlink 소켓을 만들고
receive buffer를 설정한 뒤 bind하며, 이후 poll/recv와 오류 조회에 사용한다.
원본 OTA/OOB의 UEventObserver를 없애거나 앱을 비활성화하지 않는다.

## 수정

- 전용 `nabu_stylus_ota_app` 도메인의 self:netlink_kobject_uevent_socket에
  create/bind/read/getattr/getopt/setopt만 허용한다.
- send/write, net_admin, sysfs 쓰기, permissive 또는 다른 앱 도메인 접근은 추가하지 않는다.
  legacy uevent_init은 SO_RCVBUFFORCE 실패를 무시하므로 이를 위해 net_admin을 주지 않는다.
- 실제 AOSP Bluetooth 스택과 앱 APK·원본 OTA 프로토콜은 변경하지 않는다.
- check-input-policy.py가 해당 6개 권한을 필수 검사해 재발을 놓치지 않도록 한다.

## 배터리 타입 검사 정정

이전 200abce는 소스의 sysfs_battery_supply 이름을 결합 정책에서도 그대로 요구했다.
최신 실제 결합 정책의 IDT genfs 라벨과 HAL allow 대상은 vendor_sysfs_battery_supply다.
소스 타입명과 결합 정책 타입명이 다르다는 이유만으로 오래된 산출물이라고
판정했던 것은 잘못이다. 해당 판정은 철회한다.

정책 검사 도구는 이제 실제 결합 정책에서 `/power_supply/idt` genfs 라벨을 읽고,
그 타입에 대한 HAL open/read/getattr 권한을 검사한다. 특정 타입명을 추정하지 않는다.

## 검증 범위

- 현재 nabu 결합 정책(2026-11-01 13:09 생성)에 제안한 socket allow 1개만 추가한
  **시험본**을 별도 작업 폴더에서 생성했다. 실제 out의 정책은 수정하지 않았다.
- 시험본 checkpolicy 전체 neverallow 검사 통과, 6개 소켓 권한을 개별 질의해 확인.
- 새 검사 도구로 시험본의 contexts·속성·기존 init/HAL·배터리·신규 소켓 접근 검사 통과.
- 수정하지 않은 실제 기존 정책은 소켓 create 권한 누락으로 거부됨을 확인했다(회귀 검사).
- 기존 hal_vm_capabilities_default의 빈 permission 집합 경고는 남지만 새 neverallow 오류는 없다.

이는 최종 분할 정책/CIL/VINTF 및 새 ROM 부팅 검증을 대체하지 않는다.
SELinux 정책 변경이므로 새 이미지에 포함해 플래싱한 뒤 재확인해야 한다.
기기 정책 변경·앱 설치·데이터 삭제·플래시·Bluetooth 설정 변경은 수행하지 않았다.

## 함께 관찰한 TouchFeature 조회

stock adapter가 설치되지 않은 `vendor.xiaomi.hw.touchfeature::ITouchFeature`를 조회해
`default_android_hwservice find` 거부도 발생했다. 이것은 위 소켓 생성 실패와 다른 기록이다.
기본 미설치인 stock HAL을 위한 default_android_hwservice 접근 권한을 추가하지 않았다.
정품 펜 OOB/OTA 전체 동작이나 없는 하드웨어·mode 22 지원이 이번 수정으로 완성되는 것은 아니다.

## 새 이미지 실기기 확인

1. 스타일러스·키보드 메뉴를 열고 나왔다가 다시 진입한다.
2. Bluetooth 확장 반복 종료와 UEventObserver 소켓 create/bind/read 거부가 없어졌는지 확인한다.
3. 후속 예외가 있으면 앱의 최신 크래시·AVC만 수집해 별도 원인을 확인한다.
4. 정품 펜이 없는 상태의 앱 안정성과 정품 펜을 통한 OTA·충전·OOB 검증을 구분한다.
