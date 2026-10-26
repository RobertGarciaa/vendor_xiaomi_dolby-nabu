# Input port host validation

검증 대상 소스: 작업 당시 PixelOS Android 17 framework와 Settings.
실제 nabu 제품 전체 빌드, 부팅, 펜·키보드 연결 및 펌웨어 업데이트는 수행하지 않았습니다.

- 원본 Atmos/input 그룹의 SHA256 검사 통과.
- 원본 입력 앱·OTA 앱 빌드, 플랫폼 서명 및 16KB ZIP 정렬 검사 통과.
  원본 res/assets/lib/resources.arsc 바이트 보존, OTA 주 DEX 보존 검사 포함.
- 생성 APK의 소스·APK 해시 기록으로 소스 변경 후 오래된 APK 사용을 감지합니다.
- 원본 입력 앱의 MIUI/앱 내부 호환 API 참조 153개를 정확한 메서드 서명으로 대조 통과.
- Java: 변경된 PhoneWindowManager, KeyGestureController와 NabuInputPolicy를
  현재 framework/services turbine JAR로 함께 컴파일 통과. Settings controller도
  현재 Settings/SettingsLib JAR로 컴파일 통과.
- Android.bp bpfmt 파싱, Python/XML 구문, TouchFeature VINTF manifest/matrix 검사 통과.
- 기존 참조 제품의 결합 SELinux 정책에서 이전 Dolby 규칙을 제거한 뒤 새 Atmos와
  입력 정책을 넣어 checkpolicy neverallow 활성 상태로 컴파일 통과.
  file/hwservice/property context 검사 통과. 실제 nabu 분할 정책 빌드를 대체하지 않습니다.
- TouchFeature 4개 ELF strong import가 현재 참조 출력물에서 해결됩니다.
- 패치 적용 전 현재 원본 파일 해시와 git apply --check 통과.

재현 도구: tools/verify-input.py, tools/check-input-policy.py,
extract-files.py --group all --verify-only. 참조 ELF 기록은 docs/*-elf-reference.json.

실기기에서는 설정 첫 화면/각 하위 화면, 사용자 전환, 재부팅, 키보드 연결·해제,
AltGr와 원본 단축키 편집, 잠금 화면 차단, 펜 짧게/길게 누르기, 노트 앱 페이지 키,
영역 캡처와 보안 화면 제외, 지원 IME 필기, BLE 연결·배터리·OTA 서비스 및
SELinux denial을 확인해야 합니다. USB OEM 보고서 전체는 미구현 범위입니다.
