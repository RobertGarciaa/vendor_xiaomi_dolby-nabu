# 부팅 관련 정적 점검 — 2026-10-27

검사 기준은 실제 vendor `seventeen`의 da8fb12, 외부 sm8150-common/nabu 트리와
현재 PixelOS 소스다. 기기에 설치·부팅·플래시하거나 플랫폼 소스를 수정하지 않았다.

## 결과

현재 확인 범위에서 이 저장소 때문에 즉시 부팅을 중단할 설정 오류는 발견하지 못했다.
이 결과는 전체 제품 빌드나 부팅 성공을 보증하지 않는다.

- 결합된 참고 정책의 `user`/`userdebug` neverallow 검사 통과.
- input 및 Dolby property/hwservice/file contexts의 타입 검사 통과.
- input 속성의 bool/int/enum 정의와 property info 검사 통과.
- 펜·키보드 sysfs에 대한 vendor_init chown(setattr)/write, HAL write,
  persist 속성 저장, Dolby 지원 속성 설정, audio HAL의 DMS 조회 권한 확인.
  chown은 플랫폼의 fs_type 기본 규칙이 이미 허용하므로 추가 권한은 필요하지 않다.
- 기본 설치되는 `nabu-input.rc`, `input-control.rc`, `dolby.rc`의
  host_init_verifier 검사 통과.
- 새 두 HAL의 manifest/matrix를 각각 병합하고 호환성 검사 통과.
  참고 빌드의 sepolicy version 202604, kernel policy version 30을 명시해 검사했다.
  이는 전체 nabu FCM/커널 요구 사항 검사가 아니다.
- 플랫폼 seapp_contexts와 OTA 앱의 추가 mapping 결합 검사 통과.
- 생성된 MiSound, MiuiInputSettings, NabuStylusOta, 선택적 NabuMiDevAuth APK가
  현재 ROM 플랫폼 인증서로 서명된 것을 확인했다. Soong은 최종 빌드 키로 다시 서명한다.
- 입력 앱 allowlist/default-permission은 system_ext에, DolbyControl allowlist는
  system에 설치하도록 구성했다. 최종 이미지의 전체 privapp allowlist 검사는 남는다.
- 추가 init 서비스에는 critical/reboot_on_failure 지정이 없다. 서비스 실패가 직접
  강제 재부팅으로 이어지는 구성은 아니다. 반복 서비스 실패나 오디오 HAL 장애가
  시스템 동작에 영향을 주지 않는다는 의미는 아니다.
- 스톡 TouchFeature HAL, 미완료 정품 USB 인증 서비스는 기본 설치/활성화하지 않는다.

## 검증의 한계와 실제 빌드 전 조건

정책 검사는 기존 **renoir 출력의 결합 정책**에서 해당 Dolby 규칙을 제거하고 새 규칙을
넣은 참고 검사다. sm8150의 기존 battery type 선언은 실제 QCOM legacy 소스에서 가져왔다.
전체 sm8150/nabu 정책·partitioned CIL·mapping·최종 contexts를 빌드한 결과가 아니다.
권한이 정책상 허용된다는 것과 실제 노드의 경로·DAC·부팅 시 생성 시점이 맞는 것도 별개다.

다음 조건은 아직 확인이 필요하다.

1. 외부 nabu 트리는 아직 lineage 제품 구성이다. PixelOS 제품 구성과 vendor/kernel
   배치를 완료한 뒤 전체 제품의 SELinux/VINTF/privapp 검사를 통과해야 한다.
2. 기존 common/nabu proprietary vendor 생성물의 Dolby 중복 모듈·복사 항목을 제거해야 한다.
3. 새 체크아웃에서는 ignored 파생 APK를 준비해야 한다. input/OTA 문서의 빌드 명령과
   `tools/build-devauth.py`도 확인한다. 파일 누락은 빌드 중단 원인이지 부팅 성공의 증거가 아니다.
4. 실제 init/AVC/property-service/PackageManager/오디오 HAL 로그와 재부팅 복원 검증이 남는다.
5. 현재 crDroid에서 실행한 제한적 관찰은 대상 PixelOS Android 17
   ROM의 부팅·오디오·그래픽 안정성 시험을 대신하지 않는다.

`tools/check-input-policy.py`에 위 필수 동작 권한 검사를 추가했다. 런타임 SELinux
허용 범위를 넓히거나 permissive로 바꾸는 수정은 하지 않았다.
