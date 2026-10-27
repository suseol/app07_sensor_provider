# Flutter 9주차 Lab07: 센서 대시보드와 Provider (학생용)

실습 소스 기준: **2026-10-25-r1**. `lib/`는 **STARTER 2파일 앱**입니다. 처음에는 이 코드를 실행한 뒤, 수업에 따라 직접 수정하세요.

## Android에서 시작하기

Flutter SDK, Android SDK가 준비된 컴퓨터에서 아래를 실행합니다.

```bash
git clone https://github.com/suseol/app07_sensor_provider.git
cd app07_sensor_provider
flutter doctor
flutter pub get
flutter run
```

Android 프로젝트 파일이 포함되어 있으므로 `flutter create`를 별도로 실행하지 않아도 됩니다. 인터넷에 연결되어야 Open-Meteo API 데이터를 조회할 수 있습니다. 이 앱은 날씨 모델 기반 데이터 예제로, 실물 센서 값을 직접 수집하지 않습니다.

## 실습 진행과 Checkpoints

수업에서는 `lib/`를 직접 수정합니다. `checkpoints/`는 진도를 놓쳤을 때만 복구하는 완료본입니다.

| 체크포인트 | 시점 |
| --- | --- |
| STARTER | 처음의 2파일 앱 |
| S00 | 모델, 서비스, 카드, 화면 파일 분리 완료 |
| S03 | Provider와 ViewModel 연결 완료 |
| S06 | Repository 및 Demo 실험 완료 |
| S07 | 파생 상태까지 반영한 최종 앱 |

```bash
dart run tools/use_step.dart --list
dart run tools/use_step.dart S03
```

복구 직전 `lib/` 및 `test/`는 `stage_backups/`에 자동 백업됩니다. 복구 뒤 앱을 Hot Restart하세요. `S00-03` 등 세부 절차 복구는 제공하지 않습니다.

## S06 Demo와 S07 테스트

S06 이후 `lib/main.dart`의 `useDemo`, `failAlternate` 상수를 바꿔 모의 데이터 및 번갈아 실패 상황을 확인합니다. 실습을 마치면 두 값을 `false`로 돌리세요.

마지막 실습 S07-02에서는 `provided_tests/`의 Dart 테스트 파일 5개를 `test/`에 복사해 실행합니다.

```bash
flutter analyze
flutter test
```

`dart run tools/use_step.dart S07`은 최종 코드와 제공 테스트를 함께 복구합니다. `test/`에 Flutter 기본 카운터 테스트가 있다면 제공 테스트로 교체해야 합니다.

이 저장소에는 교수자용 PDF, steps 문서, 별도의 `solution/` 폴더와 `web/` 플랫폼 파일이 들어 있지 않습니다.

## Android APK

```bash
flutter build apk --debug
```

APK 경로: `build/app/outputs/flutter-apk/app-debug.apk`. 실제 APK 빌드는 개발 PC의 Flutter, Android SDK 환경에서 확인해야 합니다.
