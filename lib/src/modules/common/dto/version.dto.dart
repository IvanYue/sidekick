import 'release.dto.dart';

/// Release version dto
class VersionDto extends ReleaseDto {
  /// Constructor
  ///
  /// [release] is the official release metadata; it is null for versions that
  /// are cached locally but do not exist in the official releases list
  /// (e.g. third-party forks like OHOS).
  VersionDto({
    required super.name,
    super.release,
    required super.needSetup,
    required super.cache,
    required super.isGlobal,
    super.isOhosSdk,
  });
}
