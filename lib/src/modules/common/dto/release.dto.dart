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
