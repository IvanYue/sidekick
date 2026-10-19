import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fvm/fvm.dart';
// ignore: implementation_imports
import 'package:fvm/src/services/process_service.dart';
import 'package:path/path.dart' as p;

import '../fvm/fvm.provider.dart';
import 'ohos.constants.dart';
import 'ohos.dto.dart';

/// Registers the OHOS fork in FVM's app config (idempotent).
///
/// Must run before [fvmContext] is first touched: `fvmContext` is a lazy
/// top-level final in `fvm.provider.dart` whose `FvmContext.create` reads
/// `.fvmrc` once. Referencing `fvmContext` in here would trigger that read
/// too early — this function must only use the [kAppConfigFile] constant.
///
/// Behavior:
/// - returns immediately if a fork named `ohos` is already registered
///   (a user-defined fork with the same alias is never overwritten);
/// - preserves any other forks already present (read-modify-write);
/// - swallows failures so a broken config file never blocks app startup;
///   a missing registration later surfaces as a visible error from
///   `getForkUrl` when the user tries to install.
Future<void> ensureOhosForkRegistered({String? appConfigPath}) async {
  final path = appConfigPath ?? kAppConfigFile;
  try {
    final config = LocalAppConfig.read(path: path);
    if (config.forks.any((f) => f.name == kOhosForkName)) return;

    config
      ..forks.add(FlutterFork(name: kOhosForkName, url: kOhosRepoUrl))
      ..save(path: path);
  } on Exception catch (e) {
    debugPrint('Could not register OHOS fork in "$path": $e');
  }
}

/// Whether the SDK checkout at [directory] was cloned from the OHOS fork.
///
/// Covers top-level checkouts without fork metadata (e.g. cloned manually):
/// the git remote in `.git/config` is matched against the CPF-Flutter
/// repository, tolerating https/ssh URL forms. Never throws — a missing or
/// unreadable config just means "not OHOS".
bool isOhosGitCheckout(String directory) {
  try {
    final config = File(p.join(directory, '.git', 'config'));
    if (!config.existsSync()) return false;

    return config.readAsStringSync().contains('CPF-Flutter/flutter_flutter');
  } on FileSystemException {
    return false;
  }
}

/// Whether a cached SDK is an OHOS install.
///
/// Covers both layouts: fork installs (`versions/ohos/<branch>`, detected via
/// `fork`) and top-level checkouts whose git remote points at the CPF-Flutter
/// repository ([topLevelOhosNames]).
///
/// Official Flutter versions can still be OHOS checkouts: a manually cloned
/// OHOS SDK published under an official version number (e.g. `3.41.9`) is in
/// the official releases list AND is an OHOS install. Badge detection must
/// therefore run on every DTO, not only on the untracked-version path.
bool isOhosCachedVersion(
  CacheFlutterVersion? cache,
  Set<String> topLevelOhosNames,
) {
  if (cache == null) return false;

  return cache.fork == kOhosForkName || topLevelOhosNames.contains(cache.name);
}

/// Release page URL for an installed OHOS SDK.
///
/// The SDK self-reports the exact fork tag in `flutter.version.json` — direct
/// evidence from the installed checkout, e.g. `3.41.9+ohos-1.0.2` — and the
/// CPF-Flutter repository publishes its releases under that tag, so this is
/// the page a user expects when clicking the installed version.
///
/// Installs track a branch (`git clone` + checkout), so the reported tag is
/// the newest release merged into that branch; the link stays valid for the
/// installed revision. Falls back to the tag list when the SDK metadata is
/// unavailable (not installed, or metadata stripped).
String ohosReleasePageUrl(CacheFlutterVersion? cache) {
  final sdkVersion = cache?.flutterSdkVersion;
  if (sdkVersion == null || sdkVersion.isEmpty) {
    return '$kOhosRepoWebUrl/tags';
  }

  return '$kOhosRepoWebUrl/releases/$sdkVersion';
}

/// Short display name for an OHOS branch or version name.
///
/// `oh-3.41.9-release` and `oh-3.41.9-dev` both render as `oh-3.41.9`
/// (the type is shown as a separate badge); variants with an extra segment
/// keep it: `oh-3.7.12-dev-6.0` renders as `oh-3.7.12-6.0`.
/// Names that don't match the OHOS pattern are returned unchanged.
String ohosDisplayName(String name) {
  final match = ohosBranchPattern.firstMatch(p.basename(name));
  if (match == null) return name;

  final version = match.namedGroup('version')!;
  final extra = match.namedGroup('extra');

  return 'oh-$version${extra != null ? '-$extra' : ''}';
}

/// Moves a freshly installed OHOS checkout from `versions/ohos/<branch>`
/// to `versions/<branch>`, so installs live next to the official ones
/// without the fork path segment.
///
/// Returns the new directory path. A checkout that already sits outside the
/// `ohos` fork directory is returned unchanged. Throws when a top-level
/// directory with the same name already exists, so callers can surface the
/// conflict instead of silently deleting an existing checkout.
Future<String> promoteOhosInstallToTopLevel(String directory) async {
  final source = Directory(directory);
  final branch = p.basename(directory);
  final forkDirPath = p.dirname(directory);

  if (!source.existsSync()) {
    throw Exception('OHOS install not found at "$directory"');
  }
  // Already outside the fork directory (e.g. top-level): nothing to do
  if (p.basename(forkDirPath) != kOhosForkName) return directory;

  final versionsRoot = p.dirname(forkDirPath);
  final target = Directory(p.join(versionsRoot, branch));
  if (target.existsSync()) {
    throw Exception(
      'A version named "$branch" already exists at the top level. '
      'Remove it first or keep the fork-layout install.',
    );
  }

  await source.rename(target.path);

  // Clean up the now-empty fork directory
  final forkDir = Directory(forkDirPath);
  if (forkDir.existsSync() && forkDir.listSync().isEmpty) {
    forkDir.deleteSync();
  }

  return target.path;
}

/// Lists OHOS release/dev branches from the remote repository.
///
/// Throws [ProcessException] on network failures; the provider layer turns
/// that into an error state with a retry button.
Future<List<OhosBranchDto>> fetchOhosBranches() async {
  final result = await fvmContext.get<ProcessService>().run('git', args: [
    'ls-remote',
    '--heads',
    kOhosRepoUrl
  ]).timeout(const Duration(minutes: 1));

  return parseOhosLsRemote(result.stdout.toString());
}

/// Parses `git ls-remote --heads` output into OHOS branches.
///
/// Input lines look like `<sha>\trefs/heads/<branch>`. Lines that don't match
/// the OHOS branch pattern (master, personal branches, etc.) are skipped.
List<OhosBranchDto> parseOhosLsRemote(String output) {
  const refPrefix = 'refs/heads/';
  final branches = <OhosBranchDto>[];

  for (final rawLine in output.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;

    final parts = line.split('\t');
    if (parts.length != 2) continue;

    final sha = parts[0].trim();
    final ref = parts[1].trim();
    if (sha.isEmpty || !ref.startsWith(refPrefix)) continue;

    final match = ohosBranchPattern.firstMatch(ref.substring(refPrefix.length));
    if (match == null) continue;

    branches.add(OhosBranchDto(
      name: ref.substring(refPrefix.length),
      type: match.namedGroup('type') == 'release'
          ? OhosBranchType.release
          : OhosBranchType.dev,
      version: match.namedGroup('version')!,
      extra: match.namedGroup('extra'),
      sha: sha,
    ));
  }

  branches.sort(_compareBranches);

  return branches;
}

/// Sorts newest version first, release before dev, then by branch name.
int _compareBranches(OhosBranchDto a, OhosBranchDto b) {
  final byVersion = _compareVersionDesc(a.version, b.version);
  if (byVersion != 0) return byVersion;
  if (a.type != b.type) {
    return a.type == OhosBranchType.release ? -1 : 1;
  }

  return a.name.compareTo(b.name);
}

/// Descending numeric comparison of dot-separated version strings.
int _compareVersionDesc(String a, String b) {
  final pa = a.split('.').map(int.tryParse).toList();
  final pb = b.split('.').map(int.tryParse).toList();

  for (var i = 0; i < pa.length && i < pb.length; i++) {
    final d = (pb[i] ?? 0).compareTo(pa[i] ?? 0);
    if (d != 0) return d;
  }

  return pb.length.compareTo(pa.length);
}

/// Returns the HEAD sha of a locally installed OHOS version, or null when it
/// cannot be read (never throws — absence just means "no update info").
Future<String?> getLocalHeadSha(String directory) async {
  try {
    final result = await fvmContext.get<ProcessService>().run(
          'git',
          args: ['rev-parse', 'HEAD'],
          workingDirectory: directory,
          throwOnError: false,
        );
    if (result.exitCode != 0) return null;

    final sha = result.stdout.toString().trim();

    return sha.isEmpty ? null : sha;
  } on Exception {
    return null;
  }
}

/// Fast-forwards a locally installed OHOS branch to the remote head.
///
/// Output is echoed to the Sidekick console via `_ConsoleProcessService`.
/// Throws [ProcessException] on failure (e.g. non-fast-forward), which the
/// queue reports to the user.
Future<void> pullOhosBranch({
  required String directory,
  required String branch,
}) async {
  await fvmContext.get<ProcessService>().run(
        'git',
        args: ['pull', '--ff-only', 'origin', branch],
        workingDirectory: directory,
        echoOutput: true,
      );
}

/// Merges remote branches with locally installed OHOS versions.
///
/// [cached] must only contain OHOS versions (fork installs and top-level
/// checkouts detected via their git remote); matching relies on `cache.name`
/// being the bare branch name (no `ohos/` prefix — that lives in
/// `nameWithAlias`).
///
/// Orphaned installs (local version whose remote branch was deleted) are kept
/// in the result with `branch: null` so they remain manageable from the UI.
/// [localShaOf] is injectable for tests.
Future<List<OhosBranchItem>> mergeOhosBranches(
  List<OhosBranchDto> remote,
  List<CacheFlutterVersion> cached,
  Future<String?> Function(String directory) localShaOf,
  String? globalVersion,
) async {
  final items = <OhosBranchItem>[];
  final consumed = <CacheFlutterVersion>[];

  for (final branch in remote) {
    final cache = cached.firstWhereOrNull((c) => c.name == branch.name);
    String? localSha;
    if (cache != null) {
      consumed.add(cache);
      localSha = await localShaOf(cache.directory);
    }
    items.add(OhosBranchItem(
      branch: branch,
      cache: cache,
      localSha: localSha,
      // Global is reported with the alias-qualified name, which is the bare
      // branch name for top-level installs
      isGlobal: cache != null && globalVersion == cache.nameWithAlias,
    ));
  }

  for (final cache in cached) {
    if (consumed.contains(cache)) continue;
    items.add(OhosBranchItem(
      branch: null,
      cache: cache,
      localSha: null,
      isGlobal: globalVersion == cache.nameWithAlias,
    ));
  }

  return items;
}
