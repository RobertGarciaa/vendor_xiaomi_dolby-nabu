# 검증 기록 (2026-10-26)

- 패드5 OS1.0.6.0.TKXMIXM에서 가져온 원본 15개 SHA256 일치.
- 스톡 HW DAP ARM32/ARM64 바이너리 descriptor와 효과 XML·앱 구현/타입 UUID 일치.
- 패드5 MiSound 입력 해시 고정, smali 보정 앵커 검증, 재조립된 DEX string_ids 정렬,
  classes2.dex와 직접 참조하는 MIUI 멤버의 **전체 시그니처** 검증.
- APK zipalign 및 apksigner 서명 검증. 이 검사는 Soong의 최종 이미지 서명 검사를 대체하지 않음.
- AAPT2로 DolbyControl 리소스/manifest 처리, 생성된 R.java와 기존 Android 17 framework.jar로
  Java 컴파일 검사. 전체 Soong 앱 빌드와 이미지는 아직 검증하지 않음.
- bpfmt의 Android.bp 파싱 검사.
- 원본·수정 DMS의 ABI 분리 생성 검사. 원본 해시·출력 해시 고정 및 단일 동적 문자열 수정.
- Dolby 바이너리 10개의 필수 동적 심볼 검사: 기존 PixelOS **renoir** Android 17 산출물을
  공통 플랫폼 라이브러리의 참고 대상으로 사용. 전부 unresolved=[].
  결과는 elf-reference-check.json에 기록. nabu 전용 빌드의 의존성 검증을 대체하지 않으며,
  dlopen 라이브러리, DSP 호출, 링커 namespace와 C++ 객체 레이아웃까지 보증하지 않음.
- 기존 renoir 결합 SELinux 정책 캐시에서 기존 Dolby 소스 블록 5개를 제거하고 현재 저장소의
  실제 정책을 m4로 새로 전개해 삽입한 뒤 checkpolicy로 neverallow 검사 통과.
  baseline 자체의 hal_vm_capabilities_default 관련 빈 권한 집합 경고 1개 존재.
  이 검사는 분할 정책·공개 정책 mapping·nabu VINTF/이미지 검사를 대체하지 않음.

실행하지 않은 항목: nabu 전체 ROM 빌드, 설치/플래시, 실기기 부팅·DSP 효과·청취·안정성 검증.
따라서 현재 포팅 후보를 실기기에서 '문제없이 동작 확인된 빌드'로 해석하면 안 됩니다.

- 수정한 디바이스 트리와 vendor 저장소의 XML 전체 파싱 통과.
- GNU Make로 Dolby 활성/비활성 두 경우를 전개하여 audio_effects.xml 복사 대상이
  정확히 하나이고 각각 vendor 대체본/공통 기본본을 선택하는지 확인.
