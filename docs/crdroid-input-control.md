# crDroid 커널용 입력 제어 서비스와 원본 앱 연결

원본 MiuiInputSettings의 스타일러스·키보드 탭과 리소스를 유지하며 옵션 메뉴에
**하드웨어 제어 / Hardware controls**를 추가합니다. 같은 앱 안의 비공개 화면에서
펜 사용, 2세대 펌웨어, 키보드 사용을 설정하고 커널 상태를 조회합니다.
한국어와 영어 문구를 제공합니다. 별도 앱을 설치하거나 원본 펌웨어 파일을 수정하지 않습니다.

## 구현 경계

앱 → vendor.pixelos.nabu.input@1.0::IInputControl/default → crDroid sysfs 경로입니다.
새 HAL은 구형 TouchFeature ABI를 가장하지 않습니다. 앱은 sysfs나 vendor 속성을 직접
쓰지 않습니다. 읽기는 system UID 앱에 한정하고 기기 전체에 영향을 주는 쓰기는
기본 사용자 system UID 1000만 허용합니다. 보조 사용자 화면은 읽기 전용입니다.

- 펜/2세대 설정: 실제 커널 노드의 0/1 값을 읽고 씁니다.
- 키보드 사용 설정: 저장된 enable_keyboard/disable_keyboard 값을 표시합니다.
  커널의 conn_status는 연결 여부이므로 사용 설정과 별도 항목으로 표시합니다.
- 측정된 배터리와 충전 전류: IDT의 reverse_pen_soc/reverse_iout를 읽습니다.
  255나 범위 밖 값, 없는 노드는 확인 불가(-1)입니다. 99%를 임의로 100%로 올리지
  않으며 전류 0만으로 펜이 미연결이라고 단정하지 않습니다. 현재 화면 새로고침 방식입니다.
- 제어 성공은 커널 요청 값 반영과 persistent property 저장까지 확인한 상태입니다.
  물리 장치가 명령을 수행했는지의 확인은 실기기 검증이 필요합니다.
- 저장에 실패하면 직전 런타임 값으로 복구를 시도하고 오류를 반환합니다.
  복구 쓰기마저 실패하면 별도 오류 -EREMOTEIO를 반환합니다.

부팅 시 init은 저장된 값 또는 최초 기본값을 펜 세대 → 펜 → 키보드 순서로 복원합니다.
기본값은 펜/키보드 켜짐, gen2 force 꺼짐입니다. 런타임 쓰기는 서비스가 수행하므로
init의 property 변경 트리거를 제거해 중복 쓰기와 입력 해제를 피했습니다.
2세대 펌웨어는 다음 펌웨어 로딩 때 선택되므로 화면 off/on 과정이 필요할 수 있습니다.
게임 모드와의 펌웨어 선택 충돌은 아직 자동 조정하지 않습니다.

## 빌드와 검증

기존 절차로 tools/build-input.py를 실행하면 원본 앱의 메뉴 훅과 비공개 activity를
포함한 APK를 생성합니다. 이 스크립트가 변경되면 의존성 기록에 따라 OTA APK도
다시 생성해야 합니다. 도구는 이전 파생물을 감지해 재빌드를 요구합니다.

```bash
python3 tools/build-input.py --rom-root /path/to/pixelos
python3 tools/build-stylus-ota.py --rom-root /path/to/pixelos
python3 tools/verify-input.py --rom-root /path/to/pixelos
python3 tools/check-input-control.py
python3 tools/check-input-policy.py --android-root /path/to/pixelos --build-variant userdebug
```

검증 결과:

- C++ 백엔드의 정상 제어·저장, 키보드 연결/사용 구분, 잘못된 요청, 노드 누락,
  저장 실패 복구, 읽기 반영 실패, 배터리 무효 값 검사: ASan/UBSan 통과.
  ptrace 환경에서 실행할 수 없는 LSan만 제외했습니다.
- 현재 Android ARM64 vendor 타깃의 컴파일 플래그와 헤더로 서비스·백엔드와
  생성된 HIDL transport/types 컴파일 통과.
- 참조 ARM64 라이브러리와 --no-undefined 결합 공유 라이브러리 링크 검사 통과.
  전체 Soong 제품 빌드나 실제 서비스 실행 검증은 아닙니다.
- APK 원본 페이로드 보존, 서명/16KB 정렬, DEX 무결성과 호환 API 참조 199개 검사 통과.
- init 문법, VINTF manifest/matrix, Android.bp 파싱, genfs를 포함한 SELinux
  neverallow 및 property/hwservice context 검사 통과.
  정책 검사는 참조 제품에 nabu의 QCOM legacy 배터리 타입 선언을 더한 결합 검사입니다.
- 실제 nabu 제품 빌드·부팅·메뉴 표시·쓰고 재부팅·충전·펜 입력은 미검증입니다.

## 남은 입력 작업

원본 앱의 SPI 펜 인식과 연결 표시, 표준 펜 버튼과 단축키 정책의 연결,
TouchFeature mode 22 등의 실제 전송 지원, 게임 모드/2세대 상호 동작,
USB OEM 인증·벤더 보고서·펌웨어 업데이트는 미완료입니다.
현재 스톡 TouchFeature HAL은 기본 제외 상태입니다. 이 새 제어 서비스가 OTA/OOB
호출 전체를 대체했다고 보아서는 안 됩니다. 충전 알림이나 원본 배터리 UI로의 연결도
현재 하드웨어 제어 화면의 측정값 조회와는 별도 후속 작업입니다.
