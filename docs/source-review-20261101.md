# nabu 포팅 및 연관 트리 재검토 — 2026-11-01

## 결론과 변경 범위

사용자가 Dolby Atmos 실기기 정상 작동을 확인했다고 알렸다. 이를 사용자 확인으로
기록하며 이번 세션에서 ADB로 재측정한 결과로 취급하지 않는다.
스타일러스·키보드 설정 진입 오류의 최근 소스 수정은 호스트 검사에 통과했다.
현재 검토 범위에서 추가 런타임 수정이 필요한 결함은 확인하지 못했다.

발견한 개선 사항은 SELinux 검사 누락이다. 최근 입력 HAL 정책은 실제 IDT 노드의
`sysfs_battery_supply` 읽기 권한으로 수정됐지만, check-input-policy.py는 다른 타입의
존재만 요구했고 이 읽기 권한을 검사하지 않았다. 해당 타입 존재 및 HAL의
open/read/getattr 권한을 필수 검증에 추가한다. SELinux allow 규칙 자체를 바꾸거나
권한을 넓히지 않는다. 정상 확인된 Dolby 엔진·튜닝·GEF 바이너리도 변경하지 않는다.

## 확인한 저장소와 시작 HEAD

| 저장소 (PixelOS 루트 기준) | 시작 HEAD | 검토 결과 |
| --- | --- | --- |
| vendor/xiaomi/dolby-nabu | f165942 | 최근 입력 API 수정·GEF 양 ABI·정책·제어 서비스 검토. 정책 검사 도구 개선 |
| vendor/xiaomi/apps-nabu | 21f6f8e | Notes·Creation·문서 앱의 기존 검증 통과. 추가 수정 없음 |
| vendor/xiaomi/nabu | f010272 | 생성 모듈 입력·복사 목록·ELF 직접 의존성 점검. 추가 수정 없음 |
| vendor/xiaomi/sm8150-common | c2a42a9 | 같은 항목 및 공통 GEF 비활성 조건 확인. 추가 수정 없음 |
| device/xiaomi/nabu | 2f658fa | 제품 플래그 순서·vendor 속성·포팅 상속·원본 추출 fixup 점검. 추가 수정 없음 |
| device/xiaomi/sm8150-common | e1f6f3d | GEF 재생성 처리·WFD 버전·Dolby 중복 제거·정책 라벨 점검. 추가 수정 없음 |

시작 시 6개 저장소는 모두 clean이었다. 사용자 담당 custom_nabu.mk와
AndroidProducts.mk는 수정하지 않았다. frameworks/base·Settings·extraPatches도 수정하지 않았다.

## 입력 설정 오류 수정 검토

기존 5ddeebb 커밋은 원본의 MIUI InputManager getPointerSpeed/setPointerSpeed/getInstance
호출 3곳을 AospCompat로 연결한다. build-input.py는 정확히 3개 변환을 요구하고,
verify-input.py는 현재 생성 APK의 소스 기록 및 프레임워크 API 참조를 검증한다.

이번 검사 결과:

- 입력 앱과 OTA 앱의 생성 소스 기록, 서명, ZIP 정렬, 중복 없는 DEX 검사 통과.
- 원본 res/assets/native 보존, OTA 원본 primary DEX 보존, 노출 서비스 경계 검사 통과.
- 입력 API 참조 227개의 정확한 시그니처 확인 통과.
- 스타일러스 API 어댑터 및 원본 OTA 서비스 존재 확인.
- input/framework/src 두 파일은 현재 ROM의 대응 NabuInputPolicy/NabuPenStatusMonitor와 일치.
- Control backend의 저장·롤백·노드 부재·유효하지 않은 요청·배터리 측정 시험 통과(ASan/UBSan).
- USB 인증의 합성 프로토콜/오류 처리 시험 통과. 이번 실행에서는 Android 어댑터 컴파일을 생략했으며
  정품 키보드 인증·OTA 실기기 성공을 의미하지 않는다.

이는 새 이미지를 통한 메뉴 진입 성공 확인을 대신하지 않는다. 사용자는 메뉴 오류 대응을
소스에 반영한 상태라고 알렸으며, 해당 수정본의 실기기 재확인은 남아 있다.
SmartDevil 일반 정전식 펜을 정품 펜으로 오인해 배터리/연결 상태를 합성하지 않는 경계를 유지한다.

## Dolby 및 앱 검사

- Dolby audit-tree: 모듈 28개, 설치 경로 경고/오류 0.
- verify-port: 원본 pin 17개, MiSound 서명/DEX/MIUI 시그니처,
  양 ABI DAP UUID, 효과 XML, GEF의 stock nabu HAL lookup 검사 통과.
- verify-apps: Notes와 Creation의 서명·정렬·페이로드·리소스·매니페스트 경계 검사 통과.
- verify-oplus-docs: 서명·정렬·원본 페이로드·소스 해시·DEX·14 JNI·직접 의존성·optional uses-library 통과.
- 기존 알려진 범위: OPlus 문서의 표·발표 등과 번역 전체를 이번에 실기기 검사한 것은 아니다.

## 두 vendor 트리의 입력과 직접 네이티브 의존성

| 항목 | nabu | sm8150-common |
| --- | ---: | ---: |
| Android.bp에서 확인한 파일 입력 | 200 | 513 |
| 정적 해석 가능한 직접 PRODUCT_COPY_FILES 입력 | 161 | 141 |
| 검사한 ELF 입력 | 173 | 504 |
| 위 파일 입력 누락 | 0 | 0 |
| 파일명 매핑 후 DT_NEEDED 선언 누락 | 0 | 0 |

모듈명과 파일명이 다를 수 있으므로 libmmosal_vendor의 stem, protobuf vendorcompat의 stem,
arch별 UBSan 런타임 파일명까지 대조했다. 단순 문자열 차이를 의존성 누락으로 오인하지 않았다.
각 vendor 네임스페이스 내부 모듈명 중복도 없었다.

이 검사는 최종 런타임 linker namespace 접근·전체 전이 심볼·C++ 객체 ABI 보장과 다르다.
최종 user 이미지의 전체 SELinux/VINTF/ABI/용량 검사는 별도로 필요하다.

## SELinux 검사 도구 개선 및 산출물 상태

현재 소스의 IDT 경로는 `sysfs_battery_supply`로 라벨링되고 입력 HAL에도 해당 파일 읽기 규칙이 있다.
기존 검사 도구는 `vendor_sysfs_battery_supply` 존재만 검사했다. 이를 실제 대상 타입으로 바꾸고
입력 HAL의 open/read/getattr 접근을 쿼리하도록 보완한다.

현재 out에 남은 combined 정책에는 최신 소스가 요구하는 `sysfs_battery_supply` 선언이 없다.
수정한 도구가 이 산출물을 즉시 거부하는 것을 확인했다. 현재 소스 정책이 실패했다는 판정이나
최종 이미지 SELinux 실패라는 의미가 아니다. 새로운 nabu 정책 산출물로 재검사해야 한다.
오래된 combined 정책을 임시 수정해 통과시키지 않았다.

전체 ROM 빌드·플래시·앱 업데이트·문서/기기 데이터 변경은 수행하지 않았다.
