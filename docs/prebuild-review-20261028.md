# Android 17 빌드 선언 및 사전 검사 도구 정리 — 2026-10-28

## 수정

실제 PixelOS Soong 검사에서 vendor.pixelos.nabu.input@1.0의 hidl_interface에 선언한
vendor_available가 지원되지 않아 전역 Blueprint 평가가 중단됐다. 이 속성을 제거했다.
현재 system/tools/hidl/build/hidl_interface.go는 생성 C++ 라이브러리에 vendor 사용
가능 속성을 자체 설정한다. HIDL ABI나 트랜잭션 번호·배터리 상태 배열은 변경하지 않았다.

APK 검사 도구는 out/host 실행 파일이 없으면 ROM의 source SDK 도구를 사용한다.
소스 SDK apksigner는 설치된 SDK와 JAR 위치가 다르므로 JDK/JAR를 직접 실행한다.
verify-input은 framework.jar 없이 공개 SDK로 확인할 수 없는 상속된 hidden API를
실제 앱 오류로 단정하지 않고 INCOMPLETE로 안내한다.

check-input-policy는 다른 기기의 결합 정책에서 규칙을 지우고 덧붙이던 참고 방식을
제거했다. 실제 nabu sepolicy_neverallows 산출물과 nabu 정책 타입을 요구하고,
전체 neverallow/타입 검사 및 init/HAL 필수 접근 권한 확인을 수행한다. 이 도구 실행은
사용자 빌드 완료 후로 미룬다. partitioned CIL/mapping/전체 contexts/VINTF를 대신하지 않는다.

DolbyControl과 정책의 설명에서 renoir/Redwood software DAP이라고 잘못 적힌 부분을
Pad 5 stock hardware DAP으로 바로잡았다. 오디오 효과 UUID·파라미터·정책 allow 규칙은
변경하지 않았다.

## 확인 범위

15개 Atmos 원본 pin 및 MiSound 서명/DEX 정렬/효과 UUID·두 ABI의 DAP descriptor,
정확한 MIUI shim member, 효과 XML 검사를 통과했다. 펜 제어 호스트 ASan/UBSan 시험과
합성 USB 인증 시험은 앞선 검토에서 통과했다. generated input/OTA APK 소스 해시는
기존 artifact record와 일치해야 한다.

현재 전체 user ROM 빌드·최종 SELinux/VINTF·최종 ABI·파티션 크기·실기기 오디오/입력
검증을 완료했다는 의미가 아니다. 사용자 요청대로 ROM 빌드를 재개하지 않는다.
입력 APK의 원본 payload/manifest 검사는 앞선 검토에서 통과했으나 현재 framework.jar를
이용한 상속 hidden API 전체 재검사는 빌드 후에 남는다.

Dolby Vision 폐기, 스톡 TouchFeature HAL/OEM USB 인증 기본 미설치 방침은 유지한다.
공통 디바이스 트리와 extraPatches는 이번 마무리에서 변경하지 않는다.

## TouchFeature 설치 규칙 중복 수정

사용자 user 빌드의 Kati 단계에서 vendor/lib{,64}/vendor.xiaomi.hardware.touchfeature@1.0.so
설치 규칙 두 개가 충돌했다. hardware/xiaomi의 생성 HIDL 모듈과 이 저장소의
nabu_touchfeature_interface prebuilt가 동일한 SONAME/설치 경로를 사용했기 때문이다.
PRODUCT_PACKAGES에서 스톡 HAL을 제외하는 것만으로 Soong의 전역 설치 규칙 생성을
막지 못한다. 원본 ABI 보관용 prebuilt에 installable: false를 지정해 설치 규칙을 없앤다.
원본 blob, 스톡 DAX/Atmos 엔진, 현재 사용하는 nabu_input_control_service는 변경하지 않는다.

이는 기본 비활성 스톡 TouchFeature HAL의 동작이나 ABI 호환성을 검증한 것이 아니다.
향후 이 HAL을 활성화하려면 커널 ABI와 함께 전용 라이브러리 격리/설치 구성을 먼저
완성해야 한다. 기존 hardware/xiaomi의 생성 라이브러리로 스톡 ABI 호환성을 가정하지 않는다.
