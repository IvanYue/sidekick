/// 打包前把 tag 的版本号写进代码。
///
/// 用法：`dart run tool/ci_stamp.dart 2.0.0`
///
/// 版本号来自 release workflow 的 tag（已去掉 `v` 前缀），需要同步两处：
/// - `pubspec.yaml` 的 `version:` —— 决定 macOS 的 Info.plist 与 Windows 产物版本
/// - `lib/src/version.dart` 的 `packageVersion` —— 「检查更新」拿它和线上最新版比对
///
/// 两处都改不到就直接失败退出，避免打出一个版本号错乱的包。
library;

import 'dart:io';

void main(List<String> args) {
  final version = args.isEmpty ? '' : args.first;
  if (version.isEmpty) {
    stderr.writeln('用法：dart run tool/ci_stamp.dart <version>');
    exit(64);
  }

  _stamp(
    'pubspec.yaml',
    RegExp(r'^version: .*$', multiLine: true),
    'version: $version',
  );
  _stamp(
    'lib/src/version.dart',
    RegExp(r'^const packageVersion = .*$', multiLine: true),
    "const packageVersion = '$version';",
  );
}

void _stamp(String path, RegExp pattern, String replacement) {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('找不到文件：$path');
    exit(1);
  }

  final source = file.readAsStringSync();
  if (!pattern.hasMatch(source)) {
    stderr.writeln('$path 里没找到要替换的行，版本号不会生效');
    exit(1);
  }

  file.writeAsStringSync(source.replaceFirst(pattern, replacement));
  stdout.writeln('$path -> $replacement');
}