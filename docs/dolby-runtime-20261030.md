# Dolby 실제 재생 경로 재검토 — 2026-10-30

## 발견과 수정

스톡 `libqtigef.so`가 기대하는 32비트 오디오 HAL 경로와 현재 설치 경로가 다르다.

- nabu `proprietary-files.txt:69`는 `audio.primary.msmnile.so`를
  `audio.primary.nabu.so`로 이름을 바꾸고 SONAME도 보정한다.
- 실제 user 빌드 산출물에는 `vendor/lib/hw/audio.primary.nabu.so`가 존재하고
  `vendor/lib/hw/audio.primary.msmnile.so`는 없다.
- ADB에서도 `/vendor/lib/hw/audio.primary.msmnile.so`는 `No such file or directory`를
  반환했다. 다른 HAL 파일의 shell 접근은 SELinux로 거부되므로 기기 쪽 해시 비교는 하지 못했다.
- `libqtigef.so` SHA256:
  `ccac6350e59bda509c6fce8ce07355a81aa916e4b5313e1710b7b22f98732d42`.
  패드5 스톡과 빌드 산출물이 일치한다.
- 이 ELF의 파일 오프셋 `0xc8c`는 `msmnile`, `0xcbd`는
  `/vendor/lib/hw/audio.primary.%s.so`이다. `gef_register_session`의 ARM32 명령
  `0x1f24` 이후는 이 보드명으로 경로를 만들어 `access`와 `dlopen`을 호출한다.
- `gef_set_param_v1`의 `0x28cc..0x28e0`은 HAL 전송 함수나 장치 문맥이 없을 때
  `-38`을 반환한다. 반환값이 언제나 이 분기에서 나왔다고 실측한 것은 아니다.
- 이전 실제 스피커 재생 로그(10-29 20:29:39.488)는
  `DlbQdspGefDriver: setEnabled() returned -38`을 기록한다. 따라서 서비스 실행,
  AudioFlinger Enabled, DSP 파일 open만으로 효과 적용 성공이라고 판단할 수 없다.

`install_symlink`로 `/vendor/lib/hw/audio.primary.msmnile.so`를
`/vendor/lib/hw/audio.primary.nabu.so`에 연결한다. 기존 HAL 하나를 그대로 재사용하며
Dolby를 선택한 제품에만 설치한다. 이 링크는 기기 이미지 안의 런타임 호환 경로이며
ROM 소스 디렉터리를 연결하는 작업용 바로가기가 아니다.
원본 Dolby 엔진, DAX 스피커 튜닝, DSP 파일과 HAL 바이너리는 수정하지 않는다.
DS2 속성의 false 값은 패드5 스톡도 동일하므로 임의로 true로 변경하지 않는다.

## 확인한 범위와 다음 검증

Soong의 `build/soong/etc/install_symlink.go`가 vendor 설치 경로와 절대 링크 대상을
지원하는 것을 확인했다. `audio.primary.nabu`는 기존 nabu vendor 제품 목록에 포함된다.
이 변경에는 신규 HAL, 프로세스, 권한, 속성, VINTF 선언이 없다.

전체 ROM 빌드/플래시 및 수정 후 실제 재생 검증은 미수행이다. 현재 설치된 기기는
수정 전 이미지이므로 아직 해결됐다고 판정하지 않는다. 다음 빌드에서 링크가 설치되고
대상이 존재하는지 확인한 후, 재생 중 GEF 전송 실패와 on/off·프리셋 청감 차이를 확인한다.
오류가 남으면 GEF 초기화와 ACDB 전송 결과를 추가 추적한다. 이어폰 경로도 별도 확인한다.

## 이번 정적 검증 결과

- `git diff --check` 통과. 새 install_symlink 모듈 단독 bpfmt 검사 통과.
- 기존 Android.bp에는 이번 수정과 무관한 dex_preopt 한 줄 표기 차이가 남아 있으며 정리하지 않았다.
- `tools/verify-port.py --rom-root /home/ccc/android/pixelos` 통과:
  원본 15파일 해시, APK 서명/DEX 정렬/MIUI 시그니처, ARM32/64 DAP UUID, 효과 XML 확인.
- ARM PC-relative literal을 파일에서 계산해 GEF의 msmnile 검색 문자열 참조를 확인했다.
- 전체 Soong/Kati 재실행은 하지 않았다. 수정 모듈의 최종 이미지 설치는 다음 빌드에서 확인한다.
