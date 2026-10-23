import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 远端数据的磁盘缓存。
///
/// 发行版列表和 OHOS 分支列表都来自网络。接口不可用（断网、镜像站被墙）时
/// 页面会整块空掉：发行版的渠道卡不渲染、项目卡片的版本选择器没有任何可选项。
/// 这里把最后一次成功拿到的响应原文落盘，网络失败时回落到它，至少还有上一次
/// 的数据可用。
///
/// 读写都只做「尽力而为」：拿不到应用支持目录（测试环境、权限异常）或读写
/// 失败都降级成「没有缓存」，不抛异常、不打断正常流程。
class RemoteCache {
  const RemoteCache._();

  /// 缓存目录 `<应用支持目录>/remote_cache`
  static Directory? _dir;

  static Future<Directory?> _directory() async {
    if (_dir != null) return _dir;

    try {
      final support = await getApplicationSupportDirectory();
      final dir = Directory(p.join(support.path, 'remote_cache'));
      if (!dir.existsSync()) dir.createSync(recursive: true);

      return _dir = dir;
    } on Exception {
      return null;
    }
  }

  /// 读取缓存原文；不存在或读不到返回 null
  static Future<String?> read(String name) async {
    try {
      final dir = await _directory();
      if (dir == null) return null;

      final file = File(p.join(dir.path, '$name.json'));
      if (!file.existsSync()) return null;

      return file.readAsStringSync();
    } on Exception {
      return null;
    }
  }

  /// 写入缓存原文；写不进去不影响功能
  static Future<void> write(String name, String content) async {
    try {
      final dir = await _directory();
      if (dir == null) return;

      File(p.join(dir.path, '$name.json')).writeAsStringSync(content);
    } on Exception {
      // 没有缓存只是下次丢失回落数据，不该影响当前流程
    }
  }
}