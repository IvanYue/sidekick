/// OHOS Flutter fork (OpenHarmony CPF-Flutter) constants.
///
/// The fork is registered in FVM's app config under [kOhosForkName] so
/// versions install through the native `versions/ohos/<branch>` layout.
const kOhosForkName = 'ohos';

/// Remote repository of the OpenHarmony Flutter fork.
///
/// Used for git operations (clone, ls-remote, fork registration), so it keeps
/// the `.git` suffix.
const kOhosRepoUrl = 'https://gitcode.com/CPF-Flutter/flutter_flutter.git';

/// Browser-facing URL of the OHOS repository.
///
/// The `.git` suffix is a git-only path segment: opening it in a browser
/// returns 403 on gitcode, so web links (badge, release notes, header icon)
/// must use this form instead.
const kOhosRepoWebUrl = 'https://gitcode.com/CPF-Flutter/flutter_flutter';

/// Matches OHOS release/dev branches of the CPF-Flutter fork.
///
/// Examples: `oh-3.41.9-release`, `oh-3.41.9-dev`, `oh-3.7.12-dev-6.0`.
/// Branch names are kept verbatim for git operations; parsed groups are only
/// used for display and sorting.
final ohosBranchPattern = RegExp(
  r'^oh-(?<version>\d+\.\d+\.\d+(?:\.\w+)*)-(?<type>release|dev)(?:-(?<extra>[\w.]+))?$',
);
