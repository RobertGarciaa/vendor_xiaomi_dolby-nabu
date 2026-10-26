# crDroid 커널에 맞춘 입력 활성화: 첫 단계

대상 커널: android_kernel_xiaomi_sm8150 a6f18ebee00e.
참고 트리: android_device_xiaomi_nabu ad4d61e의 hwcontrol pen.rs/keyboard.rs와 부팅 복원 흐름.
기존 스톡 MiuiInputSettings APK는 유지합니다. 커널과 플랫폼 코드는 변경하지 않습니다.

## 이번에 연결한 동작

vendor/etc/init/nabu-input.rc가 부팅 시 아래 순서로 실제 커널 노드에 씁니다.

1. /sys/touchpanel/pen_gen2_force: 저장된 펜 펌웨어 선택, 처음에는 0.
2. /sys/touchpanel/pen: 저장된 사용 여부, 처음에는 1(켜짐).
3. /sys/devices/platform/soc/soc:xiaomi_keyboard/xiaomi_keyboard_conn_status:
   저장된 명령, 처음에는 enable_keyboard.

순서는 펌웨어 선택 → 펜 활성화 → 키보드 활성화입니다. 재부팅 시 첫 사용 기본값보다
저장된 persistent property를 우선합니다. 같은 속성이 나중에 변경되는 경우에도
해당 노드에 반영하는 init action을 제공합니다. 입력기는 실제 펜 하드웨어가 켜진
후 별도로 필기 기능을 지원해야 합니다.

| 속성 | 허용 값 | 처음 사용 기본값 |
|---|---|---|
| persist.vendor.nabu.input.pen | 0 / 1 | 1 |
| persist.vendor.nabu.input.pen_gen2 | 0 / 1 | 0 |
| persist.vendor.nabu.input.keyboard | disable_keyboard / enable_keyboard | enable_keyboard |

이 속성은 vendor 내부 제어용입니다. 앱이나 shell에 sysfs 쓰기/속성 설정 권한을
추가하지 않았습니다. **이번 단계에서 원본 앱에 켜기/끄기 UI를 추가한 것은 아닙니다.**
현재는 빌드의 기본값과 이미 저장된 vendor 설정을 적용하는 부팅 연결입니다.
사용자 조작용 저장은 후속 vendor 서비스/앱 연결에서 구현해야 합니다. 원본 앱의
IME 필기 토글과 하드웨어 사용 여부를 같은 설정으로 취급하지 않습니다.

2세대 force 값은 다음 펌웨어 로딩 시 반영됩니다. 실행 중 변경한 뒤에는 참고
구현과 마찬가지로 화면을 껐다 켜는 과정이 필요할 수 있습니다. 커널의 게임 모드가
다른 펌웨어를 선택하면 2세대 설정과 충돌할 수 있으며 이번에는 게임 모드를 제어하지 않습니다.

## HAL 처리

crDroid 커널은 /dev/xiaomi-touch를 제공하지 않습니다. 그러므로 기본 제품 구성에서
nabu_touchfeature_hal 및 관련 필수 framework compatibility matrix를 제외했습니다.
ro.vendor.touchfeature.type=43도 기본 설정에서 제외했습니다. 원본 blobs와 빌드 모듈은
참고용으로 보존하며 TARGET_ENABLE_NABU_STOCK_TOUCHFEATURE=true로만 선택할 수 있습니다.
이 선택은 해당 스톡 커널 ABI를 구현한 별도 커널에서만 의미가 있습니다.

**이것은 TouchFeature HAL 대체 구현이 아닙니다.** 스톡 ITouchFeature를 사용하는
OTA/OOB의 hopping mode 22 등은 아직 현재 커널에 연결되지 않았습니다. 이 기능이
지원된다고 보고하지 않습니다. 다음 단계에서는 지원 가능한 호출만 sysfs/실제
전송 경로로 매핑하고, 구현할 수 없는 호출은 실패로 반환해야 합니다.

## 정책과 검증

필요한 세 sysfs 파일만 전용 genfs 타입으로 지정합니다. 공통 트리의 /touchpanel
디렉터리 타입과 다른 속성의 레이블을 유지합니다. vendor_init만 쓰도록 구성했습니다.
속성은 정확한 이름과 enum 값으로 제한합니다.

- 현재 커널 드라이버의 pen/pen_gen2 저장 함수, 키보드 명령 문자열, nabu DTS와 config 대조 통과.
- host_init_verifier로 init 문법과 property_contexts 검사 통과.
- 제품 makefile 기본/스톡 HAL 선택 평가 확인.
- 실제 genfs_contexts를 포함한 결합 SELinux 정책 검사. user와 userdebug neverallow 검사 통과.
- 전체 nabu ROM 빌드/부팅/하드웨어 연결 검증은 아직 하지 않았습니다.

다음 실기기 확인에서는 부팅 후 pen 노드 값, 키보드 USB 열거와 타이핑, 재부팅,
화면 끄기/켜기, 펜 입력을 실제로 확인해야 합니다. 이번 변경은 표준 펜 버튼의
단축키 처리, 원본 앱의 SPI 펜 인식, 충전 UI, USB OEM 인증/업데이트,
Dolby Vision을 해결한 변경이 아닙니다.
