# 추가 공개 소스 비교 — 2026-10-27

사용자가 제공한 다음 로컬 체크아웃을 읽기만 했다.

| 소스 | 검사 HEAD | 결과 |
| --- | --- | --- |
| Xiaomi_Kernel_OpenSource / nabu-r-oss | 71b6effd2dfa | nt36523, mode 20 boolean, 모드 범위 0~20 |
| kernel_pipa / pipa-t-oss | 77dc8e2290f3 | nt36532, mode 20 세대/연결 정책, 모드 범위 0~20 |
| crdroid-nabu-pen-buttons / main | 340b2c2 | NT36523 v25 측면 버튼 보고 펌웨어 수정과 검증 자료 |
| 실제 사용할 android_kernel_xiaomi_sm8150 / seventeen | a6f18ebee00e | 버튼 펌웨어 수정이 이미 포함됨 |

## mode 22

두 공개 커널의 `xiaomi_touch.h`에서 `Touch_Pen_ENABLE=20`, `Touch_Mode_NUM=21`이다.
드라이버에 mode 22의 펜 ID/TX 주파수/전압 통지 처리 경로는 없다. inband 주파수
검사 함수는 공장 진단 경로이며 원본 앱의 OOB 통지 구현으로 대체할 수 없다.

일반 setter의 `nvt_mode >= Touch_Mode_NUM && nvt_mode < 0` 조건은 범위 검사로
성립하지 않는다. 이런 경로가 성공값을 반환하더라도 지원 증거가 아니며 배열 범위
밖 접근 가능성을 검토해야 한다. 이를 이용해 mode 22를 보내는 HAL을 만들지 않는다.

공개 nabu Android R 소스와 HyperOS 스톡 Image는 mode 20 처리도 다르다.
공개 소스가 현재 스톡 바이너리 전체와 일치한다고 가정하지 않는다. 앱에 공통
mode 22 호출이 존재한다는 사실도 nabu에서 실제 사용한다는 증거가 아니다.

**결론: 현재 자료로 실제 mode 22 구현을 만들 수 없다. 현재 대상에서는 미지원이며
구현을 보류한다.** 절대적인 하드웨어 불가능을 증명한 것은 아니지만, 재개하려면
해당 컨트롤러/펌웨어에 맞는 명령 정의나 검증 가능한 통신 증거가 새로 필요하다.

## Pad 6 연결 정책을 그대로 옮기지 않는 이유

Pad 6은 블루투스 연결 수, 1세대 차단 상태, 충전, 게임 모드를 조합한다.
이는 블루투스가 없는 SmartDevil 펜에 적용할 일반 연결 판단이 아니다.
nt36532와 nabu nt36523은 별도 컨트롤러이며 같은 0x7b 명령을 쓰더라도 코드의
enable/disable 값 사용이 다르므로, Pad 6 SPI 쓰기 값을 그대로 이식하지 않는다.
현재 nabu의 명시적 입력 활성화·세대 선택 제어를 유지한다.

## 펜 버튼 수정은 이미 포함됨

현재 커널의 `firmware/novatek_nt36523_fw01.bin.ihex` 이력에
`2d2bde2dc39d`가 있다. 다음을 오프라인에서 확인했다.

- Intel HEX SHA256: `8f7f8c33910f6f3c08226531c753707667eadee8b073689001d10b12fec035aa`
- 디코딩한 196608-byte 펌웨어 SHA256:
  `851066943c2c0a77a53efb9b9892563c1c3f2a9ab24c8bb0bad5b561a53624d8`
- 참고 저장소 생성기의 Intel HEX record/전체 범위 검사와 ILM/DLM CRC 검사 통과.

따라서 패치를 중복 적용하지 않았다. 참고 자료의 Dell PN7522W 계측 결과와
정품 1세대 펜 사용자 보고는 각각의 검증 범위로만 취급한다. SmartDevil의 기능이나
현재 PixelOS Android 17 런타임 검증으로 확대하지 않는다.

2세대 강제 선택은 `novatek_nt36523_fw01_pen.bin`, 게임 모드는 별도 panel 펌웨어를
고르므로 위 버튼 수정의 검증 범위 밖이다. 현재 작업에서는 세 참고 저장소와 실제
커널에 파일 변경·커밋·부팅·플래시를 수행하지 않았다.
