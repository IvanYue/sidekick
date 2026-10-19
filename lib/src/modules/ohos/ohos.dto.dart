import 'package:fvm/fvm.dart';

import '../common/dto/version.dto.dart';
import 'ohos.constants.dart';

/// Type of an OHOS remote branch.
enum OhosBranchType { release, dev }

/// A remote branch of the OHOS Flutter fork.
class OhosBranchDto {
  const OhosBranchDto({
    required this.name,
    required this.type,
    required this.version,
    required this.sha,
    this.extra,
  });

  /// Raw branch name, e.g. `oh-3.41.9-release`.
  ///
  /// This is the single source of truth for git operations (clone, checkout,
  /// pull). Never reconstruct it from parsed parts.
  final String name;

  /// Whether this is a release or dev branch.
  final OhosBranchType type;

  /// Parsed Flutter version, e.g. `3.41.9`. Display and sorting only.
  final String version;

  /// Trailing segment after the branch type, e.g. `6.0` in
  /// `oh-3.7.12-dev-6.0`.
  final String? extra;

  /// Remote head commit of the branch.
  final String sha;

  /// Qualified version name including the fork alias, e.g.
  /// `ohos/oh-3.41.9-release`.
  String get qualifiedName => '$kOhosForkName/$name';
}

/// Merged view of a remote branch and its local installation state.
class OhosBranchItem {
  const OhosBranchItem({
    this.branch,
    this.cache,
    this.localSha,
    required this.isGlobal,
  });

  /// Remote branch info. Null when the branch no longer exists on the
  /// remote (orphaned local install).
  final OhosBranchDto? branch;

  /// Locally cached version. Null when not installed.
  final CacheFlutterVersion? cache;

  /// HEAD sha of the local installation, null when not installed or when it
  /// could not be read.
  final String? localSha;

  /// Whether this version is set as global.
  final bool isGlobal;

  bool get isInstalled => cache != null;

  /// True when the remote head moved past the local installation.
  bool get updateAvailable =>
      branch != null && localSha != null && localSha != branch!.sha;

  /// Builds the DTO to hand over to the FVM queue.
  ///
  /// Name rules (the queue re-parses it to locate the cache directory):
  /// - installed: `nameWithAlias` — matches the cache layout, so top-level
  ///   installs use the bare branch name and fork-layout installs keep the
  ///   `ohos/` prefix;
  /// - not installed: `ohos/<branch>`, so the install clones from the fork
  ///   repository instead of the official one.
  VersionDto toVersionDto() {
    final name = cache?.nameWithAlias ?? '$kOhosForkName/${branch!.name}';
    return VersionDto(
      name: name,
      release: null,
      cache: cache,
      needSetup: cache?.isSetup != true,
      isGlobal: isGlobal,
      isOhosSdk: true,
    );
  }
}
