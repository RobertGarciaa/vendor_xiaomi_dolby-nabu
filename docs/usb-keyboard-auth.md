# USB 키보드 인증 이식 — 소스 단계

현재 구현은 `nabu_keyboard_auth` Java 라이브러리와 보완한 원본 MiDevAuth APK다.
라이브러리는 `installable: false`이고 `NabuMiDevAuth`도 PRODUCT_PACKAGES에 없다.
자동 연결, 원본 설정 앱 연결, native MTD/midevauth 서비스 설치는 아직 하지 않았다.
정품 키보드가 없으므로 실제 인증·USB descriptor·펌웨어 업데이트는 미검증이다.

## 구현한 경로

- KeyboardAuth: 스톡 USB MIAUTH 요청(13바이트), key metadata + challenge 요청
  (27바이트), UID/두 metadata/token 추출, 원본 인증 결과 분류를 구현했다.
  서비스 부재나 통신 오류를 성공으로 바꾸지 않으며 오프라인 인증은 재검사 필요
  상태로 유지한다. 한 번 호출할 때 한 차례만 시도하며 자동 반복은 없다.
- StockAuthAuthority: 원본 IMiDevAuthInterface와 같은 descriptor 및 transaction
  1(getChallenge), 2(chooseKey), 3(tokenVerify)를 사용한다. 길이와 예외를 검사한다.
  원본 TEE·key 선택·서버·blacklist 판정을 대신하거나 인증을 우회하지 않는다.
  실제 연결 시 명시적 stock component와 platform 서명을 확인하는 바인딩 관리가 필요하다.
- UsbAuthTransport: VID/PID 0x3206/0x3ffc와 기존 USB 권한을 요구한다. 확인되지 않은
  configuration/alternate setting, HID 인터페이스, 모호한 vendor 인터페이스는 거절한다.
  vendor bulk IN/OUT만 보수적으로 선택하고 `claimInterface(false)`를 사용한다.
  이 topology가 정품과 일치하는지는 실물 descriptor로 확인해야 한다.
- USB 요청은 스톡처럼 64바이트로 padding하며 short write를 실패로 처리한다.
  수신은 실제 반환 길이만 사용한다. read는 최대 8회/1초, 개별 I/O timeout은 최대
  250ms다. Binder/TEE/네트워크 호출 전체의 완료 시간을 보장하는 것은 아니다.
  현재 transport는 인증 요청 두 종류만 허용하며 firmware flash/reset 명령은 없다.

응답은 선언된 길이·명령 번호·체크섬을 검사한다. byte 4의 0x31/0x32 기대값과
USB topology는 원본 명령 구조를 바탕으로 한 보수적 조건이며 실물 캡처로 확정하지
않았다. report/routing bytes 0..3은 임의로 가정하지 않는다. 체크섬은 진위 증명이
아니며 최종 판정은 원본 authority가 수행해야 한다.

## 원본 인증 APK 보완

입력은 `proprietary-usb-auth.sha256sum`으로 고정했다. `build-devauth.py`는
리소스·assets·native payload를 그대로 보존하고 다음만 변경한다.

1. 인증 앱 namespace의 직접 Log 호출 128개 제거.
2. UID/인증 정보를 내보내던 디버그 ordered broadcast 2개 제거.
   blacklist 판정과 token 검증 호출/반환 처리는 유지한다.
3. 인증 service bind에 MANAGE_USB 권한 요구. 디버그 permission을 signature로 제한.
   기존 job의 BIND_JOB_SERVICE 권한은 유지한다.

원본 로그/방송 경로를 제거한 것이 메모리의 모든 인증 문자열을 지우거나 전체
앱/라이브러리의 정보 흐름을 증명한 것은 아니다. 동의 설정 `clause_agreed`,
서버 선택과 네이티브 인증 판정은 바꾸지 않는다. 이 APK도 아직 기본 설치하지 않는다.

## 검증 및 남은 작업

```sh
python3 tools/check-keyboard-auth.py --android-root /path/to/pixelos
python3 tools/build-devauth.py --rom-root /path/to/pixelos
python3 tools/verify-devauth.py --rom-root /path/to/pixelos
```

합성 응답으로 golden request, 모든 짧은 init/token 응답 길이, 체크섬·명령 불일치,
잘못된 key/challenge, Binder 단절을 모사한 실패와 원본 결과 분류를 검사한다.
이는 실제 USB/Binder/TEE 실행 시험이 아니다. Android 어댑터는 현재 플랫폼 API에
대해 컴파일하고 D8 변환한다. 전체 nabu Soong 제품 빌드 결과는 아니다.

원본 MiDevAuthService는 midevauth@1.0 외에 mtdservice@1.2도 요구한다. 스톡
mtd@1.3의 libmt는 keymaster provision, mlipay, Widevine/OEMCrypto 등에도 연결된다.
기존 vendor 제공분과의 중복·심볼·SELinux·VINTF를 조사한 뒤 필요한 서비스만 연결해야 한다.
TEE firmware나 FID를 가짜 값으로 대체하거나 새로 provision하는 방식은 사용하지 않는다.
이 연결과 APK 런타임 검증을 마친 후 원본 설정 앱에서 lifecycle/retry/상태 표시를
연결해야 한다. 펌웨어 업데이트는 모델·버전·전원·전송 검증을 갖춘 별도 미완료 작업이다.
