import 'package:fvm/fvm.dart';

/// Flutter Relelease
abstract class ReleaseDto {
  /// Constructor
  ReleaseDto({
    required this.name,
    required this.needSetup,
    required this.cache,
    required this.release,
    this.isChannel = false,
    this.isGlobal = false,
    this.isOhosSdk = false,
  });

  /// Name
  final String name;

  /// Release
  FlutterSdkRelease? release;

  /// Cached release
  CacheFlutterVersion? cache;

  /// If needs setup
  bool needSetup;

  /// Is a channel
  bool isChannel;

  /// Is global
  bool isGlobal;

  /// Whether this is an OpenHarmony Flutter fork SDK.
  ///
  /// Single source of truth for UI badges: set for fork-installed versions
  /// (`ohos/<branch>`) and for top-level checkouts cloned from the
  /// CPF-Flutter repository (detected via the git remote in `.git/config`).
  bool isOhosSdk;

  /// Is releaes cached
  bool get isCached {
    return cache != null;
  }
}

/// 版本号的统一取值路径。
///
/// 「已安装版本」「发行版版本库」「OHOS 分支」「渠道卡」四处列表共用同一套
/// 规则：本地缓存优先，缺失时回落到远端发行元数据。
///
/// 缓存优先是必需的：渠道行（stable / beta / master）的远端元数据是「该渠道
/// 当前最新版」，只有缓存里的值才代表实际装在本地的那一版。两个 getter 都可
/// 空 —— 远端 `dart_sdk_version` 对老版本可能没有，本地缓存未 setup 或版本
/// 文件被删时也可能读不到。
extension ReleaseVersionInfo on ReleaseDto {
  /// Flutter（SDK）版本。
  ///
  /// OHOS 版本显示 fork 自报的 tag（如 `3.41.9+ohos-1.0.2`），与官方
  /// `3.41.9` 区分开。
  String? get sdkFlutterVersion => cache?.flutterSdkVersion ?? release?.version;

  /// Dart 版本。
  String? get sdkDartVersion =>
      cache?.dartSdkVersion ?? release?.dartSdkVersion;
}
