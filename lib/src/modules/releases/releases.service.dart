import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fvm/fvm.dart';

import '../common/utils/remote_cache.dart';

/// 远端发行版列表的磁盘缓存键
const kFlutterReleasesCacheKey = 'flutter_releases';

/// 拉取官方发行版列表，失败时回落到上一次成功的结果。
///
/// 取数顺序与 FVM 一致：先走 GitHub raw 的镜像 JSON（国内可达性更好），失败再
/// 回落 `storage.googleapis.com`。两边都拿不到时读磁盘缓存；缓存也没有就返回
/// null，由调用方决定如何降级（渠道卡与已安装版本仍然照常渲染）。
///
/// 任何一路成功都会把响应原文落盘，供下次离线时使用。
Future<FlutterReleasesResponse?> loadFlutterReleases() async {
  for (final url in _releaseUrls()) {
    try {
      final body = await _httpGet(url);
      final parsed = FlutterReleasesResponse.fromJson(body);
      await RemoteCache.write(kFlutterReleasesCacheKey, body);

      return parsed;
    } on Exception catch (e) {
      debugPrint('[releases] could not fetch $url: $e');
    }
  }

  // 网络全挂：用上一次成功的结果
  final cached = await RemoteCache.read(kFlutterReleasesCacheKey);
  if (cached == null) return null;

  try {
    return FlutterReleasesResponse.fromJson(cached);
  } on Exception catch (e) {
    debugPrint('[releases] could not parse cached releases: $e');
    return null;
  }
}

/// 按优先级排列的发行版列表地址
Iterable<String> _releaseUrls() {
  final platform = Platform.operatingSystem;
  final github = Platform.environment['FLUTTER_RELEASES_URL'] ??
      'https://raw.githubusercontent.com/btwld/fvm/main/releases_$platform.json';
  final storage = Platform.environment['FLUTTER_STORAGE_BASE_URL'] ??
      'https://storage.googleapis.com';

  return [
    github,
    '$storage/flutter_infra_release/releases/releases_$platform.json',
  ];
}

/// 简单 GET，非 2xx 抛 [HttpException]
Future<String> _httpGet(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode >= 400) {
      throw HttpException(
        'HTTP ${response.statusCode}: ${response.reasonPhrase} - $url',
      );
    }

    return await response.transform(const Utf8Decoder()).join();
  } finally {
    client.close();
  }
}
