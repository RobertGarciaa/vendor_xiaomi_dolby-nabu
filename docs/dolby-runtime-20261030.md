# Dolby GEF HAL 경로 수정 — 2026-10-30

## 추가 수정 — libqtigef 설치 규칙 충돌

사용자 빌드에서 `vendor/lib/libqtigef.so` 중복 설치 오류가 발생했다.
제품 목록에서 공통 모듈을 제외하는 것만으로는 Soong이 내보내는 설치 규칙이 사라지지 않았다.
이 문서 아래의 제품 목록 가드만으로 단일 소유자를 보장한다는 설명은 불충분했다.

- `dolby.mk`가 `nabu_dolby.replace_qtigef`를 Soong bool로 설정한다.
- 공통 `libqtigef`는 해당 값이 true일 때 `enabled: false`, 기본값은 true다.
- `libqtigef_nabu`는 반대로 true일 때만 활성화되고 기본값은 false다.
- 공통 추출 도구가 vendor 파일 재생성 후 같은 BP 조건과 제품 목록 가드를 복원한다.
- GEF 바이너리 패치·SONAME·설치 파일명·nabu HAL·DAX 튜닝·SELinux는 변경하지 않는다.

정적 감사와 회귀 검사, 추출 후처리 복원·멱등성 검사, 기존 verify-port 검사가 통과했다.
회귀 검사는 제품 목록만 제외하고 두 모듈을 활성 상태로 둔 이전 구성을 거부한다.
전체 Soong/Kati 및 ROM 빌드는 실행하지 않았다. 다음 사용자 빌드에서 설치 규칙이
하나만 생성되는지 확인해야 하며, 실제 효과 적용 검증은 여전히 재생 후 별도로 필요하다.

검사 명령:

```sh
python3 tools/audit-tree.py --rom-root /path/to/pixelos
python3 tools/test-qtigef-ownership.py --rom-root /path/to/pixelos
python3 tools/verify-port.py --rom-root /path/to/pixelos
```

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

`/vendor/lib/libqtigef.so`와 `/vendor/lib64/libqtigef.so`의 작성자는 각각 하나여야 한다.

- `vendor/xiaomi/sm8150-common/sm8150-common-vendor.mk`가
  `TARGET_ENABLE_XIAOMI_DOLBY`가 true일 때 `libqtigef`를 **추가하지 않는다**.
- `dolby.mk`가 `libqtigef_nabu`를 추가한다. 이 모듈은 `stem: "libqtigef"`로
  설치되므로 경로가 그대로 `/vendor/lib{,64}/libqtigef.so`다.
- 스톡 HAL(`dlopen "libqtigef.so"`)과 `libhwdap`(ARM32/64) 모두 같은 파일을 본다.

### 두 ABI 가 모두 필요하다

스톡 nabu vendor 에는 `lib/libqtigef.so`(12,712B)와 `lib64/libqtigef.so`(19,600B)가
둘 다 있다. 처음 이식에서는 32비트만 넣었는데, 그것이 **부팅을 막는다**:

`vendor/lib64/soundfx/libhwdap.so`는 `dlopen("libqtigef.so", RTLD_NOW)` 결과가
`NULL`이면 `__android_log_assert`로 프로세스를 중단한다(오프셋 `0xcbac` 의
`bl dlopen`, `0xcbb4` 의 `cbz x0, <assert>`). audioserver 는 64비트이므로
64비트 `libqtigef.so`가 없으면 효과 HAL 초기화 시 죽는다.

두 파일 모두 `msmnile` 리터럴을 갖고 `tools/gef_hal_lookup_compat.py`가 같은
방식으로 `nabu`로 바꾼다. 입력·출력 해시는 ABI 별로 따로 pin 했다.

| ABI | 입력 | 출력 |
|---|---|---|
| ARM32 | `ccac6350…` | `2a91c5d8…` |
| ARM64 | `68419da3…` | `b80cd836…` |

`tools/audit-tree.py`가 `compile_multilib: "both"`, 두 arch source, 두 blob 의
존재와 pin 을 모두 검사한다.

`overrides`와 `PRODUCT_PACKAGES -=`는 쓰지 않는다.

- `overrides: ["libqtigef"]`는 fsgen에서 `Overridden_deps`가 되고, vendor 이미지의
  **모든 아키텍처**에 대한 의존성이 된다. vendor 이미지는 `compile_multilib: "both"`라
  arm64 변형을 찾는데 공통 `libqtigef`는 ARM32 전용이므로 Soong이 중단한다:
  `dependency "//vendor/xiaomi/sm8150-common:libqtigef" ... missing variant:
  arch:arm64_armv8-2a-dotprod_kryo385`.
- Make에는 `-=` 연산자가 없다. Kati는 `PRODUCT_PACKAGES -= libqtigef`를
  `PRODUCT_PACKAGES -`라는 이름의 변수 할당으로 처리하고 목록에서 아무것도
  지우지 않는다(실측: `X := a b c` 뒤 `X -= b` → `a b c`). 그래서 이 줄은
  이중 안전장치가 아니라 무효였다.
- `tools/audit-tree.py`가 두 실수를 모두 검사한다: `-=` 사용, 그리고 공통 mk의
  `libqtigef` 추가가 Dolby 가드 밖에 있는 경우.

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
