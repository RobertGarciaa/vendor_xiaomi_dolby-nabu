# Dolby GEF HAL 경로 수정 — 2026-10-30

## 문제

두 가지가 동시에 존재했다.

1. **설치 경로 충돌**: `install_symlink`가 `vendor/lib/hw/audio.primary.msmnile.so`에
   링크를 만들었는데, qcom-caf 소스 HAL도 같은 경로에 설치한다. Kati가
   `overriding commands for target vendor/lib/hw/audio.primary.msmnile.so`로 중단했다.
2. **GEF가 HAL을 못 찾음**: 스톡 ARM32 `libqtigef.so`는 rodata의 리터럴
   `msmnile`과 `/vendor/lib/hw/audio.primary.%s.so`로 경로를 만든다. nabu는
   실제 HAL을 `audio.primary.nabu.so`로 설치하므로 GEF의 `access`/`dlopen`이
   실패하고, `gef_set_param_v1`이 HAL 전송 함수를 얻지 못해 `-38`을 반환한다.

즉 symlink만 지우면 빌드는 통과하지만 Dolby 효과는 여전히 전달되지 않는다.

## 채택한 해결

symlink를 **제거**하고, GEF의 lookup 문자열을 **nabu로 바꾼 nabu 전용
`libqtigef.so`**를 배포한다.

```
msmnile(7바이트) → nabu(4바이트) + NUL 3개
```

- 파일 오프셋·크기·섹션/프로그램 헤더·**모든 명령어가 동일**하다.
  `cmp -l`로 바뀐 바이트가 정확히 7개(문자열과 NUL 패딩)임을 확인했다.
- GEF는 `/vendor/lib/hw/audio.primary.nabu.so`를 요청한다. 이는 AudioFlinger가
  이미 로드한 **바로 그 바이너리**다. `dlopen`은 같은 핸들을 돌려주므로
  GEF 세션이 HAL의 장치 문맥을 공유한다. 별도 HAL 인스턴스가 생기지 않는다.
- 공통 `sm8150-common` blob은 손대지 않는다. 다른 sm8150 기기는 계속
  `msmnile` 경로를 쓴다.

## 왜 symlink를 쓰지 않는가

- qcom-caf 소스 HAL이 같은 경로를 이미 소유한다.
- 설령 충돌을 피해도, symlink는 `audio.primary.nabu.so`를 **다른 경로로 한 번 더**
  여는 것이므로 "같은 파일명으로 다른 HAL을 복제해 별도 인스턴스로 로드하지 말 것"
  조건에 가깝다. 리터럴을 바꾸면 애초에 같은 파일을 가리킨다.

## 재현성

생성 규칙은 `tools/gef_hal_lookup_compat.py` + `genrule`이다.
생성된 `Android.bp`만 손으로 고치는 방식이 아니므로 재추출 후에도 유지된다.

- 입력 pin `ccac6350e59bda509c6fce8ce07355a81aa916e4b5313e1710b7b22f98732d42`
  (`proprietary-files.sha256sum`에 등록, `extract-files.py --verify-only` 통과 34개)
- 출력 pin `2a91c5d827184a4fdcc86783d05c2fac20ad0454bea1821945977b496c38d0a8`
- 도구는 입력 해시가 다르면 **패치하지 않고 중단**한다. 다른 스톡 빌드에서
  엉뚱한 위치를 건드리는 것을 막는다.

## 설치 경로 단일성

`/vendor/lib/libqtigef.so`의 작성자는 하나여야 한다.

- `libqtigef_nabu`가 `overrides: ["libqtigef"]`를 선언한다. Soong이
  `PRODUCT_PACKAGES`에서 `libqtigef`를 제거하는 공식 경로다.
- `dolby.mk`가 `PRODUCT_PACKAGES -= libqtigef`를 한 번 더 수행한다(이중 안전장치).
- 모듈 stem/filename을 `libqtigef`/`libqtigef.so`로 맞춰 설치 경로가 그대로다.
  스톡 HAL(`dlopen "libqtigef.so"`)과 `libhwdap`(ARM32/64) 모두 같은 파일을 본다.

`audio.primary.msmnile.so`에 링크를 만드는 모듈은 이 저장소에 더 이상 없다.

## 검증 결과

`python3 tools/verify-port.py --rom-root /home/ccc/android/pixelos` 통과:

- 원본 pin 16개 및 `extract-files.py --verify-only` 34개 일치
- APK 서명/DEX 정렬/MIUI 시그니처, ARM32/64 DAP UUID, 효과 XML
- **신규**: GEF 패치 검증
  - 입력 해시가 pin과 일치
  - 길이 불변, 변경 바이트가 리터럴 범위 안에만 존재
  - ELF32/ARM 식별자와 프로그램 헤더 동일
  - `msmnile` 제거, `nabu` 존재, HAL 경로 포맷 문자열 보존
  - stock `audio.primary.nabu.so`가 GEF 진입점을 export하는지 확인

추가로 `bpfmt -d Android.bp` 통과, `install_symlink` 잔여 0개.

## 검증하지 않은 것 (중요)

- **전체 ROM 빌드·플래시·부팅·실제 재생은 미수행**. 사용자가 직접 한다.
- 따라서 `-38`이 사라지고 Dolby 효과가 실제로 들리는지는 아직 확인되지 않았다.
  이 문서는 "수정했다"이지 "효과가 확인됐다"가 아니다.
- 스피커/이어폰 on/off 프리셋 청감, audioserver 재시작 후 복원도 미확인.

## 사용자 재빌드 후 확인할 것

1. `ls -l /vendor/lib/libqtigef.so` — 존재하고 mtime이 새 빌드인지.
   `audio.primary.msmnile.so` **symlink가 없어야** 한다(symlink가 있으면 이전 이미지).
2. `logcat | grep -i DlbQdspGefDriver` — `setEnabled() returned -38`이 사라졌는지.
3. `dumpsys media.audio_flinger` — DAP 효과가 enabled인지.
4. 스피커·이어폰 각각에서 Atmos on/off 및 프리셋 차이 청감.
5. 오류가 남으면 `dlopen`/`dlsym` 실패 로그와 AVC를 함께 확인.
   GEF 초기화(`gef_init`)가 HAL에서 성공했는지도 확인 대상이다.
