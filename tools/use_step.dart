import 'dart:io';

const stages = {'STARTER', 'S00', 'S03', 'S06', 'S07'};

void copyDirectory(Directory from, Directory to) {
  to.createSync(recursive: true);
  for (final entry in from.listSync(followLinks: false)) {
    final name = entry.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final dest = '${to.path}/$name';
    if (entry is File) {
      entry.copySync(dest);
    } else if (entry is Directory) {
      copyDirectory(entry, Directory(dest));
    } else {
      throw FileSystemException('지원하지 않는 파일 형식입니다', entry.path);
    }
  }
}

void main(List<String> args) {
  if (args.length == 1 && args.first == '--list') {
    stdout.writeln('복구 가능: ${stages.join(', ')}');
    return;
  }
  if (args.length != 1 || !stages.contains(args.first.toUpperCase())) {
    stderr.writeln('사용법: dart run tools/use_step.dart STARTER|S00|S03|S06|S07');
    exitCode = 1;
    return;
  }

  final root = Directory.current.path;
  if (!File('$root/pubspec.yaml').existsSync()) {
    stderr.writeln('프로젝트 루트에서 실행하세요.');
    exitCode = 1;
    return;
  }

  final step = args.first.toUpperCase();
  final source = Directory(
    '$root/checkpoints/$step/lib',
  );
  if (!source.existsSync()) {
    stderr.writeln('$step 복구용 lib/가 없습니다.');
    exitCode = 1;
    return;
  }

  final staging = Directory('$root/.step_staging');
  if (staging.existsSync()) {
    stderr.writeln('.step_staging 폴더가 남아 있습니다. 내용을 확인하세요.');
    exitCode = 1;
    return;
  }

  final stamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
  final backup = Directory('$root/stage_backups/${stamp}_before_$step');

  // 변경 전 준비 단계. 실패해도 현재 lib/와 test/를 건드리지 않는다.
  try {
    copyDirectory(source, Directory('${staging.path}/lib'));
    if (step == 'S07') {
      final tests = Directory('$root/provided_tests');
      if (!tests.existsSync()) throw FileSystemException('provided_tests 없음');
      copyDirectory(tests, Directory('${staging.path}/test'));
    }
    backup.createSync(recursive: true);
    for (final name in ['lib', 'test']) {
      final current = Directory('$root/$name');
      if (current.existsSync()) {
        copyDirectory(current, Directory('${backup.path}/$name'));
      }
    }
  } catch (error) {
    if (staging.existsSync()) staging.deleteSync(recursive: true);
    stderr.writeln('복원 준비 실패: $error (기존 파일은 유지됨)');
    exitCode = 1;
    return;
  }

  try {
    for (final name in ['lib', 'test']) {
      final current = Directory('$root/$name');
      if (current.existsSync()) current.deleteSync(recursive: true);
      final prepared = Directory('${staging.path}/$name');
      if (prepared.existsSync()) prepared.renameSync(current.path);
    }
    stdout.writeln('$step 복구 완료. 이전 파일은 ${backup.path}에 백업했습니다.');
    stdout.writeln('Flutter 앱을 Hot Restart하세요.');
  } catch (error) {
    stderr.writeln('복원 실패: $error. 백업으로 되돌립니다.');
    for (final name in ['lib', 'test']) {
      final current = Directory('$root/$name');
      if (current.existsSync()) current.deleteSync(recursive: true);
      final saved = Directory('${backup.path}/$name');
      if (saved.existsSync()) copyDirectory(saved, current);
    }
    exitCode = 1;
  } finally {
    if (staging.existsSync()) staging.deleteSync(recursive: true);
  }
}
